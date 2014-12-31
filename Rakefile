require "rspec/core/rake_task"
require_relative "lib/version"
require_relative "lib/constants"
require_relative "tools/release"
require "packaging"
require "cheetah"

desc "Run RSpec code examples in spec/unit"
RSpec::Core::RakeTask.new("spec:unit") do |t|
  t.pattern = ["spec/unit/**/*_spec.rb"]
end

# Needed by packaging_rake_tasks
desc 'Alias for "spec:unit"'
task :test => ["spec:unit"]

Packaging.configuration do |conf|
  conf.obs_api = "https://api.opensuse.org"
  conf.obs_project = "Virtualization:Appliances"
  conf.package_name = "dice"
  conf.obs_target = "openSUSE_13.1"
  conf.version = Dice::VERSION

  #lets ignore license check for now
  conf.skip_license_check << /.*/
end

# Disable packaging_tasks' tarball task. We package a gem, so we don't have to
# put the sources into OBS. Instead we build the gem in the tarball task
Rake::Task[:tarball].clear
task :tarball do
  Cheetah.run "chmod", "644", "key/vagrant"
  Cheetah.run "gem", "build", "dice.gemspec"
  FileUtils.mv Dir.glob("dice-*.gem"), "package/"
end

desc "Prepare package data for submission"
RSpec::Core::RakeTask.new("rpm:prepare") do |t|
  Cheetah.run "bash", "-c", "cd lib/semaphore && ruby ./extconf.rb"
  Cheetah.run "make", "-C", "lib/semaphore"
  Cheetah.run "rm", "-f", "lib/semaphore/semaphore.o"
  release = Release.new
  release.prepare
  Rake::Task["package"].prerequisites.delete("test")
  Rake::Task['package'].invoke
end

