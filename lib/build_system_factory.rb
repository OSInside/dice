class BuildSystemFactory
  class << self
    def new(recipe)
      build_system = nil
      if Dice.config.buildhost == Dice::VAGRANT_BUILD
        Logger.info(
          "#{self}: Setting up Vagrant buildsystem"
        )
        build_system = VagrantBuildSystem.new(recipe)
      else
        hostname = Dice.config.buildhost
        Logger.info(
          "#{self}: Setting up host buildsystem for: #{hostname}"
        )
        build_system = HostBuildSystem.new(recipe)
      end
      build_system
    end
  end
end
