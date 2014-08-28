require_relative "spec_helper"

describe BuildSystem do
  before(:each) do
    allow_any_instance_of(BuildSystem).to receive(:change_working_dir)
  end

  describe "#initialize" do
    it "receives a request to change the working dir" do
      expect(BuildSystem.new("spec/helper/recipe_good")).to have_received(:change_working_dir)
    end
  end

  describe "#up" do
  end

  describe "#provision" do
  end

  describe "#halt" do
  end

  describe "#is_locked?" do
  end

  describe "#get_ip" do
    it "extracts IP from output of ip command" do
      system = BuildSystem.new("spec/helper/recipe_good")
      expect(Command).to receive(:run).and_return("foo")
      expect { system.get_ip }.to raise_error(Dice::Errors::GetIPFailed)
      expect(Command).to receive(:run).and_return("2: eth0    inet 169.254.7.246/16 brd 169.254.255.255 scope link eth0:avahi\       valid_lft forever preferred_lft forever")
      expect(system.get_ip).to eq("169.254.7.246")
    end
  end
end
