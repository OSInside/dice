require_relative "spec_helper"

describe ConnectionHostBuildSystem do
  before(:each) do
    @recipe = Recipe.new("spec/helper/recipe_good")
    expect(@recipe).to receive(:change_working_dir)
    @connection = ConnectionHostBuildSystem.new(@recipe)
    @ssh_user = @connection.instance_variable_get(:@ssh_user)
    @ssh_host = @connection.instance_variable_get(:@ssh_host)
    @ssh_private_key = @connection.instance_variable_get(:@ssh_private_key)
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
