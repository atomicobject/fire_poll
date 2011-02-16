# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fire_poll/version"

Gem::Specification.new do |s|
  s.name        = "fire_poll"
  s.version     = FirePoll::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matt Fletcher"]
  s.email       = ["fletcher@atomicobject.com"]
  s.homepage    = ""
  s.summary     = %q{Simple, brute-force method for knowing when something is ready.}
  s.description = %q{Simple, brute-force method for knowing when something is ready.}

  s.rubyforge_project = "fire_poll"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
