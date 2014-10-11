require_relative "spec_helper"

describe ConnectionFactory do
  after(:all) do
    Dice.config.buildhost = "__VAGRANT__"
  end

  before(:each) do
    @recipe="spec/helper/recipe_good"
    allow_any_instance_of(Connection).to receive(:change_working_dir)
    @factory = ConnectionFactory.new(@recipe)
  end

  describe "#connection" do
    it "returns a ConnectionVagrantBuildSystem" do
      expect(@factory.connection).to be_a(
        ConnectionVagrantBuildSystem
      )
    end

    it "returns a ConnectionHostBuildSystem" do
      Dice.config.buildhost = "localhost"
      factory = ConnectionFactory.new(@recipe)
      expect(factory.connection).to be_a(
        ConnectionHostBuildSystem
      )
    end
  end
end
