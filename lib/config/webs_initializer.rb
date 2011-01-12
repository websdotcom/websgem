module Webs
  # Loads a file named 'webs_config.yml' in the RAILS_ROOT/config directory and adds
  # values as CONSTANTS to the webs module.  This is nice for environment specific constants.
  # additionally check the webs_config.yml which should support overriding for dev & test environments
  # by adding a 'development.webs_config.yml" file.
  def self.webs_config &block
#    load_constants
    
    config = YAML.load( ERB.new( File.read("#{Rails.root.to_s}/config/webs_config.yml") ).result )[Rails.env]
    
    # CREATE CONSTANTS FOR EACH KEY
    config.each_key { |k| self.const_set(k.to_s.upcase, config[k]) }
    self.const_set('APP_PATH', "/apps/#{APP_NAME}")

    yield if block
    
    self.log_constants
  end
  
  # print out a list of constants, remove the config 
  def self.log_constants
    Rails.logger.debug( "****** WEBS CONFIG ******" );
    self.local_constants.sort.each do |lc| 
      begin
        c = const_get(lc)
        if c.is_a?( Module ) 
          c = nil
        else
          c = c.inspect if c
        end
      rescue
        c = ''
      end
      Rails.logger.debug "  #{lc} => #{c}" if !c.nil?
    end
    Rails.logger.debug( "****** END WEBS CONFIG ******" );  
  end
end