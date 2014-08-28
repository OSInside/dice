require_relative "spec_helper"

describe BuildSystem do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    @system = BuildSystem.new("spec/helper/recipe_good")
  end

  describe "#up" do
    it "raises if up failed" do
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect { @system.up }.to raise_error(Dice::Errors::VagrantUpFailed)
    end

    it "puts headline and up output on normal operation" do
      expect(@system).to receive(:puts)
      expect(Command).to receive(:run).and_return("foo")
      expect(@system).to receive(:puts).with("foo")
      @system.up
    end
  end

  describe "#provision" do
    it "raises and halts if provision failed" do
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@system).to receive(:halt)
      expect { @system.provision }.to raise_error(
        Dice::Errors::VagrantProvisionFailed
      )
    end

    it "puts headline and provision output on normal operation" do
      expect(@system).to receive(:puts)
      expect(Command).to receive(:run).and_return("foo")
      expect(@system).to receive(:puts).with("foo")
      @system.provision
    end
  end

  describe "#halt" do
    it "raises if halt failed" do
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect { @system.halt }.to raise_error(
        Dice::Errors::VagrantHaltFailed
      )    
    end

    it "puts headline and halt output on normal operation, reset_working_dir" do
      expect(@system).to receive(:puts)
      expect(Command).to receive(:run).and_return("foo")
      expect(@system).to receive(:puts).with("foo")
      expect(@system).to receive(:reset_working_dir)
      @system.halt
    end
  end

  describe "#is_locked?" do
    it "returns false if status raises" do
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@system.is_locked?).to eq(false)
    end

    it "returns true if status is running" do
      expect(Command).to receive(:run).and_return("running")
      expect(@system.is_locked?).to eq(true)
    end

    it "returns false if status is not running" do
      expect(Command).to receive(:run).and_return("shutoff")
      expect(@system.is_locked?).to eq(false)
    end
  end

  describe "#get_ip" do
    it "extracts IP from output of ip command" do
      expect(Command).to receive(:run).and_return("foo")
      expect { @system.get_ip }.to raise_error(Dice::Errors::GetIPFailed)
      expect(Command).to receive(:run).and_return("2: eth0    inet 169.254.7.246/16 brd 169.254.255.255 scope link eth0:avahi\       valid_lft forever preferred_lft forever")
      expect(@system.get_ip).to eq("169.254.7.246")
    end
  end
end
