require_relative "spec_helper"

describe Recipe do
  before(:each) do
    @cwd = "pwd"
    @description = "some-description-dir"

    allow_any_instance_of(Recipe).to receive(:get_cwd).and_return(@cwd)

    kiwi_config = double(KiwiConfig)
    allow_any_instance_of(Recipe).to receive(:kiwi_config).and_return(
      kiwi_config
    )
    allow(kiwi_config).to receive(:solve_packages)

    @recipe = Recipe.new(@description)
  end

  describe "#basepath" do
    it "raises if description does not exist or is no directory" do
      expect(File).to receive(:exists?).and_return(false)
      expect { @recipe.basepath }.to raise_error(Dice::Errors::NoDirectory)
    end
  end

  describe "#build_name_from_path" do
    it "builds a name from the absolute base path" do
      expect(@recipe).to receive(:basepath).and_return("some/path")
      expect(@recipe.build_name_from_path).to eq("some_path")
    end
  end

  describe "#setup" do
    it "loads dice and kiwi config and creates the metadata directory" do
      expect(@recipe).to receive(:load_dice_config)
      expect(@recipe).to receive(:load_kiwi_config)
      expect(@recipe).to receive(:create_metadir)
      @recipe.setup
    end
  end

  describe "validate" do
    it "raises if no kiwi config.xml exists" do
      expect(@recipe).to receive(:kiwiFile).and_return(false)
      expect { @recipe.validate }.to raise_error(Dice::Errors::NoKIWIConfig)
    end

    it "raises if no Vagrantfile and no Dicefile exists" do
      expect(@recipe).to receive(:kiwiFile).and_return(true)
      expect(@recipe).to receive(:vagrantFile).and_return(false)
      expect(@recipe).to receive(:diceFile).and_return(false)
      expect { @recipe.validate }.to raise_error(Dice::Errors::NoConfigFile)
    end
  end

  describe "#change_working_dir" do
    it "receives a Dir.chdir on description" do
      expect(@recipe).to receive(:basepath).and_return(@description)
      expect(Dir).to receive(:chdir).with(@description)
      @recipe.change_working_dir
    end
  end

  describe "#reset_working_dir" do
    it "receives a Dir.chdir containing current dir" do
      expect(Dir).to receive(:chdir).with(@cwd)
      @recipe.reset_working_dir
    end
  end

  describe "#uptodate?" do
    it "update package scan and compares the new checksum with current one" do
      expect(@recipe).to receive(:writeRecipeScan)
      expect(@recipe).to receive(:writeBuildOptions)
      expect(@recipe).to receive(:readDigest).and_return("digest")
      expect(@recipe).to receive(:calculateDigest).and_return("digest")
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
