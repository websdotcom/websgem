module Webs
  mattr_accessor :cache
  module Cache
    mattr_accessor :debug
    mattr_accessor :off
    
    def cache_remove(key)
      Rails.logger.debug "*********** cache_remove( #{key} )" if debug
      return if key.nil? || off
      Webs.cache.delete(key.to_s)
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}"
      false
    end

    def cache_read( key )
      return nil if off
      data = Webs.cache.respond_to?( 'read' ) ? Webs.cache.read(key.to_s) : Webs.cache[ key.to_s ]
      Rails.logger.debug "****#{data ? 'HIT*' : 'MISS'}*** cache_read( #{key} )" if debug
      data
      rescue Exception => e
        Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}, #{e.backtrace.join("\n")}"
        nil
    end
    
    def cache_write( key, data, options={} )
      s_data = Marshal.dump(data)
      block_size = s_data.size
      #TODO: Compression?
      if block_size < 1.megabyte
        Rails.logger.debug "*********** cache_write[#{block_size}]( #{key}, #{data && data.inspect.length > 100 ? data.inspect[0..100] : data} )" if debug
        if Webs.cache.respond_to?( 'write' )
          Webs.cache.write(key.to_s, data)
        else
          Webs.cache[ key.to_s ] = data
        end
      else
        Rails.logger.debug "*********** cache_write( #{key} ) not cached since exceeds 1M @ #{block_size} )" if debug 
      end
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}, #{e.backtrace.join("\n")}"
      nil
    end

    def get_data( &block )
      self.respond_to?('capture') ? capture(&block) : yield
    end

    def cache_block(key, options={}, &block)
      return if key.nil?
      Rails.logger.debug "*********** cache_block( #{key} )" if debug
      return get_data( &block ) if off
     
      unless ( data=cache_read(key) )
        # if self responds to capture this is called from a view which means we can cache snippets
        data = get_data( &block )
        cache_write( key.to_s, data, options )
      end
      data
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}, #{e.backtrace.join("\n")}"
      data
    end

    
    # caching snippets works very similiarly to caching a block except that snippets have already
    # been read to check for existence so we don't want to do a re-read.  So generally in the controller
    # you will do a cache_read on the key, setting a snippet @var, not do normal processing, then in view
    # do a cache_snippet which checks to see if snippet param is set if not it will cache_block the snippet
    # view otherwide just render the passed snippet
    def cache_snippet(snippet, key, options={}, &block)
      return snippet.html_safe if !snippet.blank?
      if options.delete(:ignore_cache)
        get_data( &block )
      else
        cache_block( key, options, &block )
      end
    end
  end
end
