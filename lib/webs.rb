dir = Pathname(__FILE__).dirname.expand_path

module Webs
  VERSION = "0.1.1".freeze

  ANYONE = 0
  LIMITED = 1
  MEMBERS = 2
  MODERATORS = 3
  OWNER = 4
  ADMIN = 5

  
end

require dir + 'controller/params'
require dir + 'controller/tags'
