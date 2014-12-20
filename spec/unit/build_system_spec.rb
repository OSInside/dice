require_relative "spec_helper"

describe BuildSystem do
  before(:each) do
    @recipe = Recipe.new("spec/helper/recipe_good")
    allow_any_instance_of(Recipe).to receive(:change_working_dir)
  end

  describe "#buildsystem" do
    it "returns a VagrantBuildSystem" do
      Dice.config.buildhost = Dice::VAGRANT_BUILD
      buildsystem = BuildSystem.new(@recipe)
      expect(buildsystem).to be_a(
        VagrantBuildSystem
      )
    end
  
    it "returns a HostBuildSystem" do
      Dice.config.buildhost = "localhost"
      buildsystem = BuildSystem.new(@recipe)
      expect(buildsystem).to be_a(
        HostBuildSystem
      )
    end
  end
end
