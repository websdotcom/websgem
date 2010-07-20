dir = Pathname(__FILE__).dirname.expand_path

module Webs
  VERSION = "0.1.0".freeze

end

require dir + 'controller/params'
require dir + 'controller/tags'
