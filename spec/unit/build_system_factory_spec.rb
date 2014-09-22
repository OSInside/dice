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
    allow_any_instance_of(Job).to receive(:new)
    @factory = BuildSystemFactory.new(@recipe)
  end

  describe "#buildsystem" do
    it "returns a VagrantBuildSystem" do
      expect(@factory.buildsystem).to be_a(
        VagrantBuildSystem
      )
    end
  
    it "returns a HostBuildSystem" do
      Dice.configure do |config|
        config.buildhost = "localhost"
      end
      factory = BuildSystemFactory.new(@recipe)
      expect(factory.buildsystem).to be_a(
        HostBuildSystem
      )
    end
  end

  describe "#job" do
    it "returns a Job" do
      expect(@factory.job).to be_a(Job)
    end
  end
end
