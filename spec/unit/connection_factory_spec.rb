require_relative "spec_helper"

describe ConnectionFactory do
  after(:all) do
    Dice.configure do |config|
      config.buildhost = "__VAGRANT__"
    end
  end

  before(:each) do
    @recipe="spec/helper/recipe_good"
    allow_any_instance_of(Connection).to receive(:change_working_dir)
  end

  describe "#self.from_recipe" do
    it "returns a ConnectionVagrantBuildSystem" do
      recipe="spec/helper/recipe_good"
      expect(ConnectionFactory.from_recipe(@recipe)).to be_a(
        ConnectionVagrantBuildSystem
      )
    end

    it "returns a ConnectionHostBuildSystem" do
      Dice.configure do |config|
        config.buildhost = "localhost"
      end
      expect(ConnectionFactory.from_recipe(@recipe)).to be_a(
        ConnectionHostBuildSystem
      )
    end
  end
end
