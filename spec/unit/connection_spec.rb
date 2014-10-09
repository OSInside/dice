require_relative "spec_helper"

describe Connection do
  before(:each) do
    expect_any_instance_of(Connection).to receive(:change_working_dir)
    @connection = Connection.new("spec/helper/recipe_good")
  end

  describe "#get_log" do
    it "raises if no log exists or is currently in progress" do
      expect(Command).to receive(:run).with(
        "fuser", /build_error.log/, {:stdout=>:capture}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect{ @connection.get_log }.to raise_error(Dice::Errors::NoLogFile)
    end

    it "tails the log on normal operation" do
      expect(Command).to receive(:run)
      expect(@connection).to receive(:exec).with(
        /tail -f \/.*build_error.log --pid/
      )
      @connection.get_log
    end
  end

  describe "#self.strip_fuser_pid" do
    it "extract first pid from fuser data" do
      expect(Connection.strip_fuser_pid(" 17504 17619 17713")).to eq("17504")
    end
  end
end
