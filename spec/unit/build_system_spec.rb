require_relative "spec_helper"

describe BuildSystem do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    @system = BuildSystem.new("spec/helper/recipe_good")
    @system.instance_variable_set(
      :@up_output, "[jeos_sle12_build] -- 22 => 2200 (adapter 1)"
    )
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

  describe "#get_port (with ssh forwarding)" do
    it "extracts forwarded port from vagrant up output" do
      expect(@system.get_port).to eq("2200")
      @system.instance_variable_set(:@up_output, "foo")
      expect { @system.get_port }.to raise_error(Dice::Errors::GetPortFailed)
    end
  end

  describe "#get_port (no ssh forwarding)" do
    it "returns ssh default port" do
      @system.instance_variable_set(:@use_ssh_forwarding, false)
      expect(@system.get_port).to eq(22)
    end
  end

  describe "#get_ip (no ssh forwarding)" do
    it "extracts IP from output of ip command" do
      @system.instance_variable_set(:@use_ssh_forwarding, false)
      expect(Command).to receive(:run).and_return("foo")
      expect { @system.get_ip }.to raise_error(Dice::Errors::GetIPFailed)
      expect(Command).to receive(:run).and_return("2: eth0    inet 169.254.7.246/16 brd 169.254.255.255 scope link eth0:avahi\       valid_lft forever preferred_lft forever")
      expect(@system.get_ip).to eq("169.254.7.246")
    end
  end

  describe "#get_ip (with ssh forwarding)" do
    it "returns loopback address" do
      expect(@system.get_ip).to eq("127.0.0.1")
    end
  end
end
