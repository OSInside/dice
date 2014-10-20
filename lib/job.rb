class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @job_user = Dice.config.ssh_user
    @job_ssh_private_key = Dice.config.ssh_private_key
    recipe_path = system.recipe.get_basepath
    @build_log = recipe_path + "/" + Dice::META + "/" + Dice::BUILD_LOG
    @archive  = recipe_path + "/" + Dice::META + "/" + Dice::BUILD_RESULT
    @buildsystem = system
    @ip = system.get_ip
    @port = system.get_port
  end

  def build
    prepare_build
    Logger.info("#{self.class}: Building...")
    build_opts = "--build /vagrant -d /tmp/image --logfile terminal"
    logfile = File.open(@build_log, "w")
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo /usr/sbin/kiwi #{build_opts}",
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info("#{self.class}: Build failed")
      logfile.close
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Build failed for details check: #{@build_log}"
      )
    end
    logfile.close
  end

  def bundle
    Logger.info("#{self.class}: Bundle results...")
    logfile = File.open(@build_log, "a")
    bundle_opts = "--bundle-build /tmp/image --bundle-id DiceBuild " +
      "--destdir /tmp/bundle --logfile terminal"
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo /usr/sbin/kiwi #{bundle_opts}",
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info("#{self.class}: Bundler failed")
      logfile.close
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Bundle result failed for details check: #{@build_log}"
      )
    end
    logfile.close
  end

  def get_result
    Logger.info("#{self.class}: Retrieving results in #{@archive}...")
    result = File.open(@archive, "w")
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo tar --exclude image-root -C /tmp/bundle -c .",
        :stdout => result
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info("#{self.class}: Archiving failed")
      result.close
      @buildsystem.halt
      raise Dice::Errors::ResultRetrievalFailed.new(
        "Archiving result failed with: #{e.stderr}"
      )
    end
    result.close
  end

  private

  def prepare_build
    Logger.info("#{self.class}: Preparing build...")
    FileUtils.rm(@archive) if File.file?(@archive)
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo rm -rf /tmp/image /tmp/bundle"
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info("#{self.class}: Preparation failed")
      @buildsystem.halt
      raise Dice::Errors::PrepareBuildFailed.new(
        "Preparing build environment failed with: #{e.stderr}"
      )
    end
  end
end
