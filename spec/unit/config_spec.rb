require_relative "spec_helper"

describe DiceConfig do
  before(:each) do
    @config = DiceConfig.new
  end

  describe "#initialize" do
    it "sets default values" do
      buildhost = @config.instance_variable_get(:@buildhost)
      ssh_private_key = @config.instance_variable_get(:@ssh_private_key)
      ssh_user = @config.instance_variable_get(:@ssh_user)
      expect(ssh_user).to eq("vagrant")
      expect(ssh_private_key).to match(/dice\/key\/vagrant/)
      expect(buildhost).to eq(Dice::VAGRANT_BUILD)
    end
  end

  describe "#buildhost=" do
    it "sets the buildhost instance variable" do
      @config.buildhost= "bob"
      buildhost = @config.instance_variable_get(:@buildhost)
      expect(buildhost).to eq("bob")
    end
  end

  describe "#ssh_private_key=" do
    it "sets the ssh_private_key instance variable" do
      @config.ssh_private_key= "bob"
      ssh_private_key = @config.instance_variable_get(:@ssh_private_key)
      expect(ssh_private_key).to eq("bob")
    end
  end

  describe "#ssh_user=" do
    it "sets the ssh_user instance variable" do
      @config.ssh_user= "bob"
      ssh_user = @config.instance_variable_get(:@ssh_user)
      expect(ssh_user).to eq("bob")
    end
  end
end
