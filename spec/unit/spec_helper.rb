require File.expand_path('../../../lib/dice', __FILE__)

bin_path = File.expand_path( "../../../bin/", __FILE__ )

if ENV['PATH'] !~ /#{bin_path}/
  ENV['PATH'] = bin_path + File::PATH_SEPARATOR + ENV['PATH']
end

RSpec.configure do |config|
  config.before(:each) do

    allow_any_instance_of(Kernel).to receive(:print)
    allow(STDOUT).to receive(:puts)
    allow(STDERR).to receive(:puts)
  end
end

