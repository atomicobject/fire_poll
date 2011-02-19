# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fire_poll/version"

Gem::Specification.new do |s|
  s.name        = "fire_poll"
  s.version     = FirePoll::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Fletcher", "David Crosby", "Micah Alles"]
  s.email       = ["fletcher@atomicobject.com", "crosby@atomicobject.com", "alles@atomicobject.com"]
  s.homepage    = ""
  s.summary     = %q{Simple, brute-force method for knowing when something is ready}
  s.description = %q{Simple, brute-force method for knowing when something is ready}

  s.rubyforge_project = "fire_poll"

  s.add_development_dependency("bundler", ">= 1.0.0")
  s.add_development_dependency("rake", ">= 0.8.0")
  s.add_development_dependency("yard", "~> 0.6.4")
  s.add_development_dependency("bluecloth", "~> 2.0.11")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
