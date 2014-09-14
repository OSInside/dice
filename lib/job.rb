class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @job_user = Dice.config.ssh_user
    @job_ssh_private_key = Dice.config.ssh_private_key
    recipe_path = system.get_basepath
    @buildlog = recipe_path + "/buildlog"
    @archive  = recipe_path + ".build_results.tar"
    @buildsystem = system
    @ip = system.get_ip
    @port = system.get_port
  end

  def build
    prepare_build
    Logger.info "Building..."
    build_opts = "--build /vagrant -d /tmp/image --logfile /buildlog"
    begin
      Command.run(
        "ssh", "-p", @port, "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo /usr/sbin/kiwi #{build_opts} "
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Build failed"
      get_buildlog
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Build job failed for details check: #{@buildlog}"
      )
    end
  end

  def get_result
    Logger.info "Retrieving results in #{@archive}..."
    result = File.open(@archive, "w")
    begin
      Command.run(
        "ssh", "-p", @port, "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo tar --exclude image-root -C /tmp/image -c .",
        :stdout => result
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Archiving failed"
      @buildsystem.halt
      raise Dice::Errors::ResultRetrievalFailed.new(
        "Archiving results failed with: #{e.stderr}"
      )
    end
  end

  private

  def prepare_build
    Logger.info "Preparing build..."
    FileUtils.rm(@buildlog) if File.file?(@buildlog)
    FileUtils.rm(@archive) if File.file?(@archive)
    begin
      Command.run(
        "ssh", "-p", @port, "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo rm -rf /tmp/image; sudo touch /buildlog"
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Preparation failed"
      @buildsystem.halt
      raise Dice::Errors::PrepareBuildFailed.new(
        "Prepare build env failed with: #{e.stderr}"
      )
    end
  end

  def get_buildlog
    Logger.info "Retrieving build log..."
    logfile = File.open(@buildlog, "w")
    begin
      Command.run(
        "ssh", "-p", @port, "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo cat /buildlog", :stdout => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Retrieving build log failed"
      FileUtils.rm logfile
      @buildsystem.halt
      raise Dice::Errors::LogFileRetrievalFailed.new(
        "Reading log file failed with: #{e.stderr}"
      )
    end
  end
end
