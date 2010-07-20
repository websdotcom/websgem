dir = Pathname(__FILE__).dirname.expand_path

module Webs
  VERSION = "0.1.0".freeze

  module Controllers
    autoload :Helpers, 'controller/params'
  end

end
