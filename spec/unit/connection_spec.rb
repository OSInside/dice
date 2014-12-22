require_relative "spec_helper"

describe Connection do
  before(:each) do
    description = "some-description-dir"
    @recipe = Recipe.new(description)
    allow(@recipe).to receive(:basepath).and_return(description)
    allow(@recipe).to receive(:change_working_dir)
  end

  describe "#connection" do
    it "returns a ConnectionVagrantBuildSystem" do
      Dice.config.buildhost = Dice::VAGRANT_BUILD
      connection = Connection.new(@recipe)
      expect(connection).to be_a(
        ConnectionVagrantBuildSystem
      )
    end

    it "returns a ConnectionHostBuildSystem" do
      Dice.config.buildhost = "localhost"
      connection = Connection.new(@recipe)
      expect(connection).to be_a(
        ConnectionHostBuildSystem
      )
    end
  end
end
