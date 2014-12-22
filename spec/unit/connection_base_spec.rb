require_relative "spec_helper"

describe ConnectionBase do
  before(:each) do
    @description = "some-description-dir"
    recipe = Recipe.new(@description)
    allow(recipe).to receive(:basepath).and_return(@description)
    allow(recipe).to receive(:change_working_dir)
    @connection = ConnectionBase.new(recipe)
  end

  describe "#get_log" do
    it "raises if no log exists or is currently in progress" do
      expect(Command).to receive(:run).with(
        "fuser", /build\.log/, {:stdout=>:capture}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect{ @connection.get_log }.to raise_error(Dice::Errors::NoLogFile)
    end

    it "tails the log on normal operation" do
      expect(Command).to receive(:run)
      expect(@connection).to receive(:exec).with(
        /tail -f #{@description}\/.dice\/build.log --pid/
      )
      @connection.get_log
    end
  end

  describe "#print_log" do
    it "print build log file if present" do
      expect(File).to receive(:read).with(/build\.log/).and_return("foo")
      expect(@connection).to receive(:puts).with("foo")
      @connection.print_log
    end

    it "raises if no log file exists" do
      expect(File).to receive(:read).with(/build\.log/).and_raise
      expect{ @connection.print_log }.to raise_error(Dice::Errors::NoLogFile)
    end
  end
end
