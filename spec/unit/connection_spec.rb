require_relative "spec_helper"

describe Connection do
  before(:each) do
    expect_any_instance_of(Connection).to receive(:change_working_dir)
    @system = Connection.new("spec/helper/recipe_good")
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
      expect(Connection.strip_fuser_pid(" 17504 17619 17713")).to eq("17504")
    end
  end
end
