class ConnectionFactory
  class << self
    def new(recipe)
      connection = nil
      if Dice.config.buildhost == Dice::VAGRANT_BUILD
        Dice.logger.info(
          "#{self}: Connecting to Vagrant virtualized buildsystem"
        )
        connection = ConnectionVagrantBuildSystem.new(recipe)
      else
        hostname = Dice.config.buildhost
        Dice.logger.info(
          "#{self}: Connection to host buildsystem: #{hostname}"
        )
        connection = ConnectionHostBuildSystem.new(recipe)
      end
      connection
    end
  end
end
