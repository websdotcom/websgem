# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{webs}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chuck Olczak"]
  s.date = %q{2010-07-23}
  s.description = %q{Reusable webs stuff.}
  s.email = %q{chuck@webs.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/controller/webs_controller.rb", "lib/helper/params.rb", "lib/helper/tags.rb", "lib/webs.rb"]
  s.files = ["README.rdoc", "Rakefile", "lib/controller/webs_controller.rb", "lib/helper/params.rb", "lib/helper/tags.rb", "lib/webs.rb", "webs.gemspec"]
  s.homepage = %q{http://github.com/websdotcom/websgem}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Webs", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{webs}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Reusable webs stuff.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
