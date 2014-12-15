require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "dice"
  s.version     = Dice::VERSION
  s.license     = "GPL-3.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["SUSE"]
  s.email       = ["ms@suse.com"]
  s.homepage    = "https://github.com/schaefi/dice/"
  s.summary     = "light weight image build system"
  s.description = "
    Given there is the need to build a kiwi appliance for a customer,
    one wants to keep track of the updates from the distribution and
    software vendors according to the components used in the appliance.
    This leads to a regular rebuild of that appliance which should be
    automatically triggered whenever the repository which stores all
    the software packages has changed. With Dice there is a tool which
    automatically builds all appliances stored in a directory
  "

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "dice"

  s.add_dependency "cheetah", ">=0.4.0"
  s.add_dependency "gli", "~> 2.11.0"
  s.add_dependency "abstract_method", ">=1.2.1"
  s.add_dependency "json", ">=1.8.0"
  s.add_dependency "inifile", ">=2.0.2"

  s.files        = Dir["lib/**/*.rb", "bin/*", "completion/*", "key/*", "recipes/**/*", "COPYING"]
  s.executables  = "dice"
  s.require_path = "lib"

  s.add_development_dependency "rake"
  s.add_development_dependency "packaging_rake_tasks"
end
