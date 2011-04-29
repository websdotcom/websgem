# Rakefile
require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('webs', '0.1.30') do |p|
  p.description    = "Reusable webs stuff."
  p.url            = "https://colczak@github.com/websdev/websgem.git"
  p.author         = "Chuck Olczak"
  p.email          = "chuck@webs.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
