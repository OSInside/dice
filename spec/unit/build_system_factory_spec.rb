require_relative "spec_helper"

describe BuildSystemFactory do
  before(:each) do
    @recipe = Recipe.new("spec/helper/recipe_good")
    allow_any_instance_of(Recipe).to receive(:change_working_dir)
  end

  describe "#buildsystem" do
    it "returns a VagrantBuildSystem" do
      Dice.config.buildhost = Dice::VAGRANT_BUILD
      factory = BuildSystemFactory.new(@recipe)
      expect(factory).to be_a(
        VagrantBuildSystem
      )
    end
  
    it "returns a HostBuildSystem" do
      Dice.config.buildhost = "localhost"
      factory = BuildSystemFactory.new(@recipe)
      expect(factory).to be_a(
        HostBuildSystem
      )
    end
  end
end
