require_relative "spec_helper"

describe ConnectionFactory do
  before(:each) do
    @recipe = Recipe.new("spec/helper/recipe_good")
    allow_any_instance_of(Recipe).to receive(:change_working_dir)
  end

  describe "#connection" do
    it "returns a ConnectionVagrantBuildSystem" do
      Dice.config.buildhost = Dice::VAGRANT_BUILD
      factory = ConnectionFactory.new(@recipe)
      expect(factory).to be_a(
        ConnectionVagrantBuildSystem
      )
    end

    it "returns a ConnectionHostBuildSystem" do
      Dice.config.buildhost = "localhost"
      factory = ConnectionFactory.new(@recipe)
      expect(factory).to be_a(
        ConnectionHostBuildSystem
      )
    end
  end
end
