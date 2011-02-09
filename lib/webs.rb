dir = Pathname(__FILE__).dirname.expand_path

require dir + 'config/webs_constants'
require dir + 'controller/webs_controller'
require dir + 'helper/application'
require dir + 'helper/params'
require dir + 'helper/tags'

module Webs
  VERSION = '0.1.16'.freeze

#  def self.load_constants
    # s = File.read("#{Pathname(__FILE__).dirname.expand_path}/config/webs_constants.yml")
    # Rails.logger.debug ERB.new( File.read("#{Pathname(__FILE__).dirname.expand_path}/config/webs_constants.yml") ).result
    # config = YAML.load( ERB.new( File.read("#{Pathname(__FILE__).dirname.expand_path}/config/webs_constants.yml") ).result )
    # 
    # # CREATE CONSTANTS FOR EACH KEY
    # config.each_key do |k| 
    #   v = config[k]
    #   # convert strings to symbols
    #   # TODO: might need to do children
    #   if v.is_a?(Hash)
    #     h = {}
    #     v.each_key { |vk| vk.is_a?(String) ? h[vk.to_sym] = v[vk] : h[vk] = v[vk] }
    #     v = h
    #   end
    #   self.const_set(k.to_s.upcase, v)
    # end
    # map_permission_levels
#  end
  
  # def self.map_permission_levels
  #   h = {}
  #   PERMISSION_LEVEL.each_value{ |v| h[v['value']] = v }
  #   self.const_set('PERMISSION_LEVELS_BY_VALUE', h)
  #   self.const_set('PERMISSION_LEVELS', PERMISSION_LEVEL.keys)
  # end
  
  def self.app_title
    APP_NAME.titleize
  end
  
  class Railtie < Rails::Railtie
    initializer 'webs_view-path' do |app|
      path = "#{Pathname(__FILE__).dirname.expand_path}/views"
      app.paths.app.views.push path
    end
  end
end

