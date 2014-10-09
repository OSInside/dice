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

  describe "#is_busy?" do
    it "raises MethodNotImplemented" do
      expect { @system.is_busy? }.to raise_error(
        Dice::Errors::MethodNotImplemented
      )
    end
  end

  describe "#set_lock" do
    it "creates a lock file" do
      lockfile = double(File)
      expect(File).to receive(:new).with(/\.dice\/lock/, "w").and_return(
        lockfile
      )
      expect(lockfile).to receive(:close)
      @system.set_lock
    end
  end

  describe "#release_lock" do
    it "removes a possibly existing lock file" do
      expect(File).to receive(:file?).with(/\.dice\/lock/).and_return(true)
      expect(FileUtils).to receive(:rm).with(/\.dice\/lock/)
      @system.release_lock
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
end
