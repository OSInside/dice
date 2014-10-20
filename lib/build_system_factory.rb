class BuildSystemFactory
  def initialize(recipe)
    if Dice.config.buildhost == Dice::VAGRANT_BUILD
      Logger.info("#{self.class}: Setting up Vagrant virtualized buildsystem")
      @build_system = VagrantBuildSystem.new(recipe)
    else
      hostname = Dice.config.buildhost
      Logger.info("#{self.class}: Setting up buildsystem for host: #{hostname}")
      @build_system = HostBuildSystem.new(recipe)
    end
  end

  def buildsystem
    @build_system
  end

  def job
    Job.new(@build_system)
  end
end
