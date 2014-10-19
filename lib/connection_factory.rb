class ConnectionFactory
  def initialize(description)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info(
        "#{self.class}: Connecting to Vagrant virtualized buildsystem"
      )
      @connection = ConnectionVagrantBuildSystem.new(description)
    else
      hostname = Dice.config.buildhost
      Logger.info(
        "#{self.class}: Connection to host buildsystem: #{hostname}"
      )
      @connection = ConnectionHostBuildSystem.new(description)
    end
  end

  def connection
    @connection
  end
end
