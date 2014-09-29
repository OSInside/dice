require_relative "spec_helper"

describe Cli do
  describe "#error_handling" do
    it "shows stderr, stdout and the backtrace for unexpected errors" do
      expect(Logger).to receive(:error).with("dice unexpected error")
      expect(Logger).to receive(:error).with(/Backtrace:/)
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
