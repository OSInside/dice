class DockerBuildSystem < BuildSystemBase
  def get_lockfile
    # set a recipe specific lock
    # building the same recipe multiple times is possible if the
    # buildsystem is a container or a vm but not useful. Thus we
    # prevent that by a recipe lock
    lock = recipe.basepath + "/" + Dice::META + "/" + Dice::LOCK
    lock
  end

  def up
    Dice.logger.info(
      "#{self.class}: Pulling buildsystem from dockerhub #{recipe.basepath}..."
    )
    begin
      up_output = Command.run(
        "docker", "pull", "opensuse/kiwi", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::DockerPullFailed.new(
        "Pulling opensuse/kiwi failed with: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: #{up_output}")
  end

  def provision
    # provision a docker container is done when running the job
    # by bind mounting host volumes to the container. There is
    # no syncing of folders required at this stage
    nil
  end

  def halt
    container_name = recipe.build_name_from_path
    Dice.logger.info("#{self.class}: Delete container...")
    begin
      halt_output = Command.run(
        "docker", "rm", container_name, :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.error(
        "#{self.class}: Deletion of container failed with: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: #{halt_output}")
    recipe.reset_working_dir
  end

  def job_builder_command(action)
    container_name = recipe.build_name_from_path
    command = [
      "docker", "run",
      "--entrypoint=sudo",
      "--privileged=true",
      "--name=#{container_name}",
      "-v", "#{recipe.basepath}:/vagrant",
      "opensuse/kiwi", "sudo #{action}"
    ]
    command
  end

  def port
    # the docker container is not accessed via ssh
    nil
  end

  def host
    # the docker container is not accessed via ssh
    nil
  end

  def private_key_path
    # the docker container is not accessed via ssh
    nil
  end

  def is_busy?
    # docker container is never busy, because started by us
    false
  end
end
