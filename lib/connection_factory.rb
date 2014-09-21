class ConnectionFactory
  def self.from_recipe(recipe)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info("Connecting to Vagrant virtualized buildsystem")
      return ConnectionVagrantBuildSystem.new(recipe)
    else
      Logger.info("Connection to host buildsystem: #{Dice.config.buildhost}")
      return ConnectionHostBuildSystem.new(recipe)
    end
  end
end
