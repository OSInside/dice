require_relative "spec_helper"

describe ConnectionVagrantBuildSystem do
  before(:each) do
    @recipe = Recipe.new("spec/helper/recipe_good")
    expect(@recipe).to receive(:change_working_dir)
    @connection = ConnectionVagrantBuildSystem.new(@recipe)
  end

  describe "#ssh" do
    it "runs vagrant ssh" do
      expect(@connection).to receive(:exec).with(
        /vagrant ssh/
      )
      @connection.ssh
    end
  end
end
