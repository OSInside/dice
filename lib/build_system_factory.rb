class BuildSystemFactory
  def self.from_recipe(recipe)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info("Setting up Vagrant virtualized buildsystem")
      return VagrantBuildSystem.new(recipe)
    else
      Logger.info("Setting up buildsystem for host: #{Dice.config.buildhost}")
      return HostBuildSystem.new(recipe)
    end
  end
end
