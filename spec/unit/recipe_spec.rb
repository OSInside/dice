require_relative "spec_helper"

describe Recipe do
  describe "#initialize" do
    before(:each) do
      allow_any_instance_of(Recipe).to receive(:change_working_dir).
        and_return(true)
    end

    it "raises if description does not exist or is no directory" do
      expect { Recipe.new("foo") }.to raise_error(Dice::Errors::NoDirectory)
    end

    it "returns a Recipe for good recipe" do
      expect(Recipe.new("helper/recipe_good")).to be_a(Recipe)
    end

    it "raises if Vagrantfile is missing" do
      expect { Recipe.new("helper/recipe_missing_vagrantfile") }.
        to raise_error(Dice::Errors::NoVagrantFile)      
    end

    it "raises if config.xml is missing" do
      expect { Recipe.new("helper/recipe_missing_config.xml") }.
        to raise_error(Dice::Errors::NoKIWIConfig)
    end
  end

  describe "get_basepath" do
    it "returns absolut path name containing helper/recipe_good" do
      recipe = Recipe.new("helper/recipe_good")
      expect(recipe.get_basepath).to match(/^\/.*\/helper\/recipe_good/)
    end
  end
end
