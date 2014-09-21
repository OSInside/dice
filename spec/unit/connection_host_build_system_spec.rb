require_relative "spec_helper"

describe ConnectionHostBuildSystem do
  before(:each) do
    expect_any_instance_of(Connection).to receive(:change_working_dir)
    @connection = ConnectionHostBuildSystem.new("spec/helper/recipe_good")
  end

  describe "#get_log" do
    it "raises if no log exists or is currently in progress" do
      expect(Command).to receive(:run).with(
        "ssh", "-i", /key\/vagrant/, "vagrant@__VAGRANT__",
        "sudo", "fuser", "/buildlog", {:stdout=>:capture}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect{ @connection.get_log }.to raise_error(Dice::Errors::NoLogFile)
    end

    it "tails the log on normal operation" do
      expect(Command).to receive(:run)
      expect(@connection).to receive(:exec).with(
        /ssh -i .*key\/vagrant vagrant@__VAGRANT__ tail -f \/buildlog --pid/
      )
      @connection.get_log
    end
  end
end
