class BuildSystem
  class << self
    attr_reader :recipe

    def new(recipe)
      @recipe = recipe
      build_system = nil
      if Dice.config.buildhost == Dice::VAGRANT_BUILD
        Dice.logger.info(
          "#{self}: Setting up Vagrant buildsystem"
        )
        build_system = vagrant_build_system
      elsif Dice.config.buildhost == Dice::DOCKER_BUILD
        Dice.logger.info(
          "#{self}: Setting up Docker buildsystem"
        )
        build_system = docker_build_system
      else
        hostname = Dice.config.buildhost
        Dice.logger.info(
          "#{self}: Setting up host buildsystem for: #{hostname}"
        )
        build_system = host_build_system
      end
      build_system
    end

    private

    def docker_build_system
      DockerBuildSystem.new(recipe)
    end

    def vagrant_build_system
      VagrantBuildSystem.new(recipe)
    end

    def host_build_system
      HostBuildSystem.new(recipe)
    end
  end
end
