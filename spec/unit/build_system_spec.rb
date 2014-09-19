require_relative "spec_helper"

describe BuildSystem do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    @system = BuildSystem.new("spec/helper/recipe_good")
  end

  describe "#up" do
    it "raises MethodNotImplemented" do
      expect { @system.up }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#provision" do
    it "raises MethodNotImplemented" do
      expect { @system.provision }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#halt" do
    it "raises MethodNotImplemented" do
      expect { @system.halt }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#is_locked?" do
    it "raises MethodNotImplemented" do
      expect { @system.is_locked? }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#get_port" do
    it "raises MethodNotImplemented" do
      expect { @system.get_port }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#get_ip" do
    it "raises MethodNotImplemented" do
      expect { @system.get_ip }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#get_log" do
    it "raises MethodNotImplemented" do
      expect { @system.get_log }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#self.strip_fuser_pid" do
    it "extract first pid from fuser data" do
      expect(BuildSystem.strip_fuser_pid(" 17504 17619 17713")).to eq("17504")
    end
  end
end
