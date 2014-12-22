require_relative "spec_helper"

describe ConnectionVagrantBuildSystem do
  before(:each) do
    description = "some-description-dir"
    recipe = Recipe.new(description)
    allow(recipe).to receive(:basepath).and_return(description)
    allow(recipe).to receive(:change_working_dir)

    @connection = ConnectionVagrantBuildSystem.new(recipe)
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
