require_relative "spec_helper"

describe HostBuildSystem do
  before(:each) do
    Dice.config.buildhost = "example.com"
    description = "some-description-dir"
    @recipe = Recipe.new(description)
    allow(@recipe).to receive(:basepath).and_return(description)
    allow(@recipe).to receive(:change_working_dir)

    @system = HostBuildSystem.new(@recipe)
    @host = @system.instance_variable_get(:@host)
  end

  describe "#get_lockfile" do
    it "returns the correct lock file for a host buildsystem" do
      expect(@system.get_lockfile).to eq("/tmp/.lock-example.com")
    end
  end

  describe "#up" do
    it "checks if build worked is busy with other task" do
      expect(Dice::logger).to receive(:info).with(/#{@host}/)
      expect(@system).to receive(:is_busy?).and_return(true)
      expect { @system.up }.to raise_error(
        Dice::Errors::BuildWorkerBusy
      )
    end
  end

  describe "#provision" do
    it "calls rsync to transfer the recipe to the buildhost" do
      expect(Command).to receive(:run).with(
        "rsync", "-e",
        /ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -i .*key\/vagrant/,
        "--rsync-path", "sudo rsync", "-z", "-a", "-v", "--delete",
        "--exclude", ".*", ".", "vagrant@#{@host}:/vagrant",
        {:stdout=>:capture}
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
      expect(Command).to receive(:run).with(
        "ssh", "-o", "StrictHostKeyChecking=no", "-o",
        "NumberOfPasswordPrompts=0", "-i", /key\/vagrant/,
        "vagrant@#{@host}", "sudo", "killall", "kiwi"
      )
      expect(@recipe).to receive(:reset_working_dir)
      @system.halt
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

  describe "#is_busy?" do
    it "checks if another kiwi process runs on the worker" do
      expect(Command).to receive(:run).with(
        "ssh", "-o", "StrictHostKeyChecking=no", "-o",
        "NumberOfPasswordPrompts=0", "-i", /key\/vagrant/,
        "vagrant@#{@host}", "sudo", "pidof", "-x", "kiwi"
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@system.is_busy?).to eq(false)
    end
  end
end
