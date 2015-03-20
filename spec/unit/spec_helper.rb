require File.expand_path('../../../lib/dice', __FILE__)

bin_path = File.expand_path( "../../../bin/", __FILE__ )

if ENV['PATH'] !~ /#{bin_path}/
  ENV['PATH'] = bin_path + File::PATH_SEPARATOR + ENV['PATH']
end

RSpec.configure do |config|
  config.before(:each) do
    options = OpenStruct.new
    allow(Dice.logger).to receive(:info)
    allow(Dice).to receive(:option).and_return(options)
  end
end

