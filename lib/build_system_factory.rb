class BuildSystemFactory
  def initialize(recipe)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info("Setting up Vagrant virtualized buildsystem")
      @build_system = VagrantBuildSystem.new(recipe)
    else
      Logger.info("Setting up buildsystem for host: #{Dice.config.buildhost}")
      @build_system = HostBuildSystem.new(recipe)
    end
  end

  def buildsystem
    @build_system
  end

  def job
    Job.new(@build_system)
  end

  def solver
    Solve.new(@build_system)
  end
end
