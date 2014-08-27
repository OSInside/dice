require_relative "spec_helper"

describe Recipe do
  describe "#initialize" do
    it "raises if description does not exist or is no directory" do
      expect { Recipe.new("foo") }.to raise_error(Dice::Errors::NoDirectory)
    end

    it "returns a Recipe for good recipe" do
      expect(Recipe.new("spec/helper/recipe_good")).to be_a(Recipe)
    end

    it "raises if Vagrantfile is missing" do
      expect { Recipe.new("spec/helper/recipe_missing_vagrantfile") }.
        to raise_error(Dice::Errors::NoVagrantFile)      
    end

    it "raises if config.xml is missing" do
      expect { Recipe.new("spec/helper/recipe_missing_config.xml") }.
        to raise_error(Dice::Errors::NoKIWIConfig)
    end
  end

  describe "get_basepath" do
    it "returns absolut path name containing helper/recipe_good" do
      recipe = Recipe.new("spec/helper/recipe_good")
      expect(recipe.get_basepath).to match(/^\/.*\/helper\/recipe_good/)
    end
  end

  describe "change_working_dir" do
    it "receives a Dir.chdir containing helper/recipe_good" do
      recipe = Recipe.new("spec/helper/recipe_good")
      expect(Dir).to receive(:chdir).with(/^\/.*\/helper\/recipe_good/)
      recipe.change_working_dir
    end
  end

  describe "reset_working_dir" do
    it "receives a Dir.chdir containing current dir" do
      cwd = Dir.pwd
      recipe = Recipe.new("spec/helper/recipe_good")
      expect(Dir).to receive(:chdir).with(cwd)
      recipe.reset_working_dir
    end
  end
end
