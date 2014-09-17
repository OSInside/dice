require_relative "spec_helper"

describe BuildSystemFactory do
  after(:all) do
    Dice.configure do |config|
      config.buildhost = "__VAGRANT__"
    end
  end

  before(:each) do
    @recipe="spec/helper/recipe_good"
    allow_any_instance_of(BuildSystem).to receive(:change_working_dir)
  end

  describe "#self.from_recipe" do
    it "returns a VagrantBuildSystem" do
      recipe="spec/helper/recipe_good"
      expect(BuildSystemFactory.from_recipe(@recipe)).to be_a(
        VagrantBuildSystem
      )
    end
  
    it "returns a HostBuildSystem" do
      Dice.configure do |config|
        config.buildhost = "localhost"
      end
      expect(BuildSystemFactory.from_recipe(@recipe)).to be_a(
        HostBuildSystem
      )
    end
  end
end
