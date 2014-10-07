require_relative "spec_helper"

describe Cli do
  describe "#self.handle_error" do
    it "shows stderr, stdout and the backtrace for unexpected errors" do
      expect(Logger).to receive(:error).with(/^dice unexpected error/)
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

  describe "#self.error_log_file" do
    it "returns error log file for given task" do
      buildtask = double(BuildTask)
      Cli.instance_variable_set(:@task, buildtask)
      expect(buildtask).to receive(:error_log_file).and_return("foo")
      expect(Cli.error_log_file).to eq("foo")
    end
  end
end
