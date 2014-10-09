class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @job_user = Dice.config.ssh_user
    @job_ssh_private_key = Dice.config.ssh_private_key
    recipe_path = system.get_basepath
    @error_log = recipe_path + "/" + Dice::META + "/" + Dice::BUILD_ERROR_LOG
    @archive  = recipe_path + "/" + Dice::META + "/" + Dice::BUILD_RESULT
    @buildsystem = system
    @ip = system.get_ip
    @port = system.get_port
  end

  def build
    prepare_build
    Logger.info "Building..."
    build_opts = "--build /vagrant -d /tmp/image --logfile terminal"
    logfile = File.open(@error_log, "w")
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo /usr/sbin/kiwi #{build_opts}",
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Build failed"
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Build failed for details check: #{@error_log}"
      )
    end
  end

  def bundle
    Logger.info "Bundle results..."
    logfile = File.open(@error_log, "a+")
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
      Logger.info "Bundler failed"
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Bundle result failed for details check: #{@error_log}"
      )
    end
  end

  def get_result
    Logger.info "Retrieving results in #{@archive}..."
    result = File.open(@archive, "w")
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo tar --exclude image-root -C /tmp/bundle -c .",
        :stdout => result
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Archiving failed"
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
    Logger.info "Preparing build..."
    FileUtils.rm(@archive) if File.file?(@archive)
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo rm -rf /tmp/image /tmp/bundle; sudo touch /buildlog"
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Preparation failed"
      @buildsystem.halt
      raise Dice::Errors::PrepareBuildFailed.new(
        "Preparing build environment failed with: #{e.stderr}"
      )
    end
  end
end
