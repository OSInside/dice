class ConnectionFactory
  def initialize(recipe)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info("Connecting to Vagrant virtualized buildsystem")
      @connection = ConnectionVagrantBuildSystem.new(recipe)
    else
      Logger.info("Connection to host buildsystem: #{Dice.config.buildhost}")
      @connection = ConnectionHostBuildSystem.new(recipe)
    end
  end

  def connection
    @connection
  end
end
