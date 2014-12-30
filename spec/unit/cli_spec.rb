require_relative "spec_helper"

describe Cli do
  describe "#self.handle_error" do
    it "shows stderr, stdout and the backtrace for unexpected errors" do
      expect(Dice::logger).to receive(:error).with(/^dice unexpected error/)
      expect(Dice::logger).to receive(:error).with(/^Please file a bug/)
      expect(Dice::logger).to receive(:error).with(/^backtrace/)
      # match backtrace
      expect(Dice::logger).to receive(:error)
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
