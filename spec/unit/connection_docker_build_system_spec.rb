require_relative "spec_helper"

describe ConnectionDockerBuildSystem do
  before(:each) do
    description = "some/description/dir"
    recipe = Recipe.new(description)
    allow(recipe).to receive(:basepath).and_return(description)
    allow(recipe).to receive(:change_working_dir)

    @connection = ConnectionDockerBuildSystem.new(recipe)
  end

  describe "#ssh" do
    it "runs docker exec" do
      expect(@connection).to receive(:exec).with(
        "docker exec -ti some_description_dir bash"
      )
      @connection.ssh
    end
  end
end
