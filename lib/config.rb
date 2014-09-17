class DiceConfig
  attr_accessor :buildhost
  attr_accessor :ssh_private_key
  attr_accessor :ssh_user

  def initialize
    # default host is localhost which triggers the use of vagrant
    @buildhost = Dice::VAGRANT_BUILD
    # default ssh private key is the vagrant key
    @ssh_private_key = File.join(Dice::ROOT, "key/vagrant")
    # default ssh user is vagrant
    @ssh_user = "vagrant"
  end

  def buildhost=(name) 
    @buildhost = name
  end

  def ssh_private_key=(key)
    @ssh_private_key = key
  end

  def ssh_user=(user)
    @ssh_user = user
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
