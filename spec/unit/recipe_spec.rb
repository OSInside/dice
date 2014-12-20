require_relative "spec_helper"

describe Recipe do
  before(:each) do
    allow(FileUtils).to receive(:mkdir).with(/recipe_good\/.dice/)
    @recipe = Recipe.new("spec/helper/recipe_good")
  end

  describe "#initialize" do
    it "raises if description does not exist or is no directory" do
      expect { Recipe.new("foo") }.to raise_error(Dice::Errors::NoDirectory)
    end

    it "returns a Recipe for good recipe" do
      expect(@recipe).to be_a(Recipe)
    end

    it "raises if Vagrantfile is missing" do
      expect { Recipe.new("spec/helper/recipe_missing_vagrantfile") }.
        to raise_error(Dice::Errors::NoConfigFile)
    end

    it "raises if config.xml is missing" do
      expect { Recipe.new("spec/helper/recipe_missing_config.xml") }.
        to raise_error(Dice::Errors::NoKIWIConfig)
    end
  end

  describe "#change_working_dir" do
    it "receives a Dir.chdir containing helper/recipe_good" do
      expect(Dir).to receive(:chdir).with(/^\/.*\/helper\/recipe_good/)
      @recipe.change_working_dir
    end
  end

  describe "#reset_working_dir" do
    it "receives a Dir.chdir containing current dir" do
      cwd = Dir.pwd
      expect(Dir).to receive(:chdir).with(cwd)
      @recipe.reset_working_dir
    end
  end

  describe "#uptodate?" do
    it "update package scan and compares the new checksum with current one" do
      package_solver = double
      kiwi_config = double(KiwiConfig)
      expect(KiwiConfig).to receive(:new).with(@recipe.basepath).and_return(
        kiwi_config
      )
      expect(Solver).to receive(:new).with(kiwi_config).and_return(
        package_solver
      )
      expect(package_solver).to receive(:solve)
      expect(@recipe).to receive(:writeRecipeScan)
      expect(@recipe).to receive(:readDigest).and_return("foo")
      expect(@recipe).to receive(:calculateDigest).and_return("foo")
      expect(@recipe.uptodate?).to eq(true)
    end
  end

  describe "#update" do
    it "update the recipe checksum and writes a new one" do
      expect(@recipe).to receive(:writeRecipeChecksum)
      @recipe.update
    end
  end
end
