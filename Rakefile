# Rakefile
require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('webgem', '0.1.0') do |p|
  p.description    = "Reusable webs stuff."
  p.url            = "git@github.com:websdev/websgem.git"
  p.author         = "Chuck Olczak"
  p.email          = "chuck@webs.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }