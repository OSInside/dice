require_relative "spec_helper"

describe ConnectionHostBuildSystem do
  before(:each) do
    description = "some-description-dir"
    recipe = Recipe.new(description)
    allow(recipe).to receive(:basepath).and_return(description)
    allow(recipe).to receive(:change_working_dir)

    @connection = ConnectionHostBuildSystem.new(recipe)
    @ssh_user = Dice.config.ssh_user
    @ssh_host = Dice.config.buildhost
    @ssh_private_key = Dice.config.ssh_private_key
  end

  describe "#ssh" do
    it "calls ssh" do
      expect(@connection).to receive(:exec).with(
        "ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -i #{@ssh_private_key} #{@ssh_user}@#{@ssh_host}"
      )
      @connection.ssh
    end
  end

end
