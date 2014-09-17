require_relative "spec_helper"

describe HostBuildSystem do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    @system = HostBuildSystem.new("spec/helper/recipe_good")
    @host = @system.instance_variable_get(:@host)
  end

  describe "#up" do
    it "adds a log information about the used host" do
      expect(Logger).to receive(:info).with(/#{@host}/)
      @system.up
    end
  end

  describe "#provision" do
    it "calls rsync to transfer the recipe to the buildhost" do
      expect(Command).to receive(:run).with(
        "rsync", "-e", /ssh -i .*key\/vagrant/, "--rsync-path",
        "sudo rsync", "-z", "-a", "-v", "--exclude", ".*", ".",
        "vagrant@__VAGRANT__:/vagrant", {:stdout=>:capture}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@system).to receive(:halt)
      expect { @system.provision }.to raise_error(
        Dice::Errors::HostProvisionFailed
      )
    end
  end

  describe "#halt" do
    it "resets the working dir" do
      expect(@system).to receive(:reset_working_dir)
      @system.halt
    end
  end

  describe "#is_locked?" do
    it "checks lock status via pidof" do
      expect(Command).to receive(:run).with(
        "ssh", "-i", /key\/vagrant/, "vagrant@__VAGRANT__",
        "pidof -x kiwi"
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@system.is_locked?).to eq(false)
    end
  end

  describe "#get_port" do
    it "returns standard ssh port" do
      expect(@system.get_port).to eq("22")
    end
  end

  describe "#get_ip" do
    it "returns ip or host name" do
      expect(@system.get_ip).to eq(@host)
    end
  end

  describe "#get_log" do
    it "raises if no log exists or is currently in progress" do
      expect(Command).to receive(:run).with(
        "ssh", "-i", /key\/vagrant/, "vagrant@__VAGRANT__",
        "sudo", "fuser", "/buildlog", {:stdout=>:capture}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect{ @system.get_log }.to raise_error(Dice::Errors::NoLogFile)
    end

    it "tails the log on normal operation" do
      expect(Command).to receive(:run)
      expect(@system).to receive(:exec).with(
        /ssh -i .*key\/vagrant vagrant@__VAGRANT__ tail -f \/buildlog --pid/
      )
      @system.get_log
    end
  end
end
