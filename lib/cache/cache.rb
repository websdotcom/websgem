module Webs
  mattr_accessor :cache
  module Cache
    mattr_accessor :debug
    
    def cache_remove(key)
      Rails.logger.debug "*********** cache_remove(#{key})" if debug
      return if key.nil?
      Webs.cache.delete(key.to_s)
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}"
      false
    end
    
    def cache_block(key, options=nil, &block)
      Rails.logger.debug "*********** cache_block(#{key}, #{options.inspect if options} )" if debug
      return if key.nil?
      
      if Webs.cache.respond_to?( 'read' )
        data = Webs.cache.read(key)
      else
        data = Webs.cache[ key ]
      end
      unless data
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
          Rails.logger.debug "*********** cache_block[#{block_size}](#{key}, #{data} )" if debug
          if Webs.cache.respond_to?( 'write' )
            Webs.cache.write(key, data)
          else
            Webs.cache[ key ] = data
          end
        else
          Rails.logger.debug "*********** block not cached since exceeds 3M @ #{block_size} )" if debug
        end
      else
        Rails.logger.debug "****HIT**** cache_block(#{key}, #{data} )" if debug
      end
      data
    rescue Exception => e
      Rails.logger.error "------------------------------------------------\nmemcache_error: #{e.message}, #{e.backtrace.join("\n")}"
      data
    end
  end
end