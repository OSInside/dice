class DiceConfig
  attr_accessor :buildhost
  attr_accessor :ssh_private_key
  attr_accessor :ssh_user

  def initialize
    # default buildhost is a vagrant identification symbol
    # which triggers the use of vagrant
    @buildhost = Dice::VAGRANT_BUILD
    # default ssh private key is the vagrant key
    @ssh_private_key = Dice::SSH_PRIVATE_KEY_PATH
    # default ssh user is vagrant
    @ssh_user = Dice::SSH_USER
  end
end

module Dice
  @config = DiceConfig.new

  def self.config
    @config
  end

  def self.configure
    yield @config
  end
end
