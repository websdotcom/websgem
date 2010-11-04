dir = Pathname(__FILE__).dirname.expand_path

require dir + 'controller/webs_controller'
require dir + 'helper/params'
require dir + 'helper/tags'

module Webs
  VERSION = "0.1.6".freeze

  module Permission
    DISABLED = -1
    ANYONE = 0
    LIMITED = 1
    MEMBERS = 2
    MODERATORS = 3
    OWNER = 4
    ADMIN = 5
  end
  
end

