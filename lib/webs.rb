dir = Pathname(__FILE__).dirname.expand_path

require dir + 'config/webs_constants'
require dir + 'controller/webs_controller'
require dir + 'helper/application'
require dir + 'helper/params'
require dir + 'helper/tags'

module Webs
  VERSION = '0.1.45'.freeze

  def self.app_title
    APP_NAME.titleize
  end
 
  if defined?( Rails::Railtie )
    class Railtie < Rails::Railtie
      initializer 'webs_view-path' do |app|
        path = "#{Pathname(__FILE__).dirname.expand_path}/views"
        app.paths.app.views.push path
      end
    end
  end
end

