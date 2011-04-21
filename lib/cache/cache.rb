module Webs
  mattr_accessor :cache
  module Cache
    mattr_accessor :debug
    mattr_accessor :off
    
    def cache_remove(key)
      Rails.logger.debug "*********** cache_remove(#{key})" if debug
      return if key.nil?
      Webs.cache.delete(key.to_s)
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}"
      false
    end

    def cache_read( key )
      Rails.logger.debug "*********** cache_read(#{key})" if debug
      if Webs.cache.respond_to?( 'read' )
        Webs.cache.read(key)
      else
        Webs.cache[ key ]
      end
    end

    def cache_block(key, options=nil, &block)
      return if key.nil?
      if off
        if self.respond_to?('capture')
          data = capture(&block) # called from view
        else
          data = yield
        end
        Rails.logger.debug "****OFF**** cache_block(#{key})"
        return data
      end
      
      unless ( data=cache_read(key) )
        if self.respond_to?('capture')
          data = capture(&block) # called from view
        else
          data = yield
        end
        s_data = Marshal.dump(data)
        block_size = s_data.size
        #TODO: Check to see if dalli cache & compressed then up the size to 3MB
        # should get almost 10:1 compression ratio. This will be key for caching pages & fragments
        if block_size < 1.megabyte
          Rails.logger.debug "*********** cache_block[#{block_size}](#{key}, #{data && data.inspect.length > 100 ? data.inspect[0..100] : data} )" if debug
          if Webs.cache.respond_to?( 'write' )
            Webs.cache.write(key, data)
          else
            Webs.cache[ key ] = data
          end
        else
          Rails.logger.debug "*********** cache_block(#{key}) not cached since exceeds 3M @ #{block_size} )" if debug 
        end
      else
        Rails.logger.debug "****HIT**** cache_block(#{key} )" if debug && !off
      end
      data
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}, #{e.backtrace.join("\n")}"
      data
    end
  end
end
