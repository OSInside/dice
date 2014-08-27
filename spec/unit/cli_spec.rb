require_relative "spec_helper"

describe Cli do
  describe "#initialize" do
    before :each do
      allow_any_instance_of(IO).to receive(:puts)
    end
  end

  describe "#error_handling" do
    it "shows stderr, stdout and the backtrace for unexpected errors" do
      expect(STDERR).to receive(:puts).with("dice unexpected error")
      expect(STDERR).to receive(:puts).with(/Backtrace:/)
      begin
        # raise some exception, so we have a backtrace
        raise(Cheetah::ExecutionFailed.new(
          nil, nil, "This is STDOUT", "This is STDERR")
        )
      rescue => e
        expect{ Cli.handle_error(e) }.to raise_error(SystemExit)
      end
    end
  end
end
