require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "dice"
  s.version     = Dice::VERSION
  s.license     = "GPL-3.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["SUSE"]
  s.email       = ["ms@suse.com"]
  s.homepage    = "https://github.com/schaefi/dice/"
  s.summary     = "build system for kiwi images using vagrant"
  s.description = "build system for kiwi images using vagrant"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "dice"

  s.add_dependency "cheetah", ">=0.4.0"
  s.add_dependency "gli", "~> 2.11.0"
  s.add_dependency "pathname"
  s.add_dependency "fileutils"

  s.files        = Dir["lib/**/*.rb", "bin/*", "COPYING"]
  s.executables  = "dice"
  s.require_path = "lib"

  s.add_development_dependency "rake"
end
