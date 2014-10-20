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

  describe "#ok?" do
    it "loads Dicefile and creates .dice dir" do
      expect(@recipe).to receive(:load)
      @recipe.instance_eval{ ok? }
    end
  end

  describe "#get_basepath" do
    it "returns absolut path name containing helper/recipe_good" do
      expect(@recipe.get_basepath).to match(/^\/.*\/helper\/recipe_good/)
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

  describe "#createDigest" do
    it "creates expected sha256 digest" do
      expect(Find).to receive(:find).with(".").
        and_return(["spec/helper/recipe_good/config.xml"])
      expect(@recipe.instance_eval{ createDigest }).to eq(
        "spec/helper/recipe_good/config.xml:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\n"
      )
    end
  end

  describe "#writeRecipeChecksum" do
    it "wants to create .checksum.sha256" do
      digest_file = double(File)
      expect(@recipe).to receive(:createDigest).and_return("foo")
      expect(File).to receive(:new).with(
        "#{@recipe.get_basepath}/.dice/checksum.sha256", "w"
      ).and_return(digest_file)
      expect(digest_file).to receive(:puts)
      expect(digest_file).to receive(:close)
      @recipe.writeRecipeChecksum
    end
  end

  describe "#readDigest" do
    it "reads and returns current digest" do
      expect(File).to receive(:read).with(".dice/checksum.sha256").
        and_return("foo")
      expect(@recipe.instance_eval{ readDigest }).to eq("foo")
    end
  end

  describe "#job_required?" do
    it "compares two digests" do
      expect(@recipe).to receive(:readDigest).and_return("foo")
      expect(@recipe).to receive(:createDigest).and_return("foo")
      expect(@recipe.job_required?).to eq(false)
    end
  end
end
