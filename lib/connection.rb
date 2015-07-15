class Connection
  class << self
    attr_reader :recipe

    def new(recipe)
      @recipe = recipe
      connection = nil
      if Dice.config.buildhost == Dice::VAGRANT_BUILD
        Dice.logger.info(
          "#{self}: Connecting to Vagrant virtualized buildsystem"
        )
        connection = vagrant_connection
      elsif Dice.config.buildhost == Dice::DOCKER_BUILD
        Dice.logger.info(
          "#{self}: Connecting to Docker container"
        )
        connection = docker_connection
      else
        hostname = Dice.config.buildhost
        Dice.logger.info(
          "#{self}: Connection to host buildsystem: #{hostname}"
        )
        connection = host_connection
      end
      connection
    end

    private

    def docker_connection
      ConnectionDockerBuildSystem.new(recipe)
    end

    def vagrant_connection
      ConnectionVagrantBuildSystem.new(recipe)
    end

    def host_connection
      ConnectionHostBuildSystem.new(recipe)
    end
  end
end
