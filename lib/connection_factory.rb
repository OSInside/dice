class ConnectionFactory
  def initialize(recipe)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info(
        "#{self.class}: Connecting to Vagrant virtualized buildsystem"
      )
      @connection = ConnectionVagrantBuildSystem.new(recipe)
    else
      hostname = Dice.config.buildhost
      Logger.info(
        "#{self.class}: Connection to host buildsystem: #{hostname}"
      )
      @connection = ConnectionHostBuildSystem.new(recipe)
    end
  end

  def connection
    @connection
  end
end
