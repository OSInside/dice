class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @job_user = Dice.config.ssh_user
    @job_ssh_private_key = Dice.config.ssh_private_key
    recipe_path = system.get_basepath
    @buildlog = recipe_path + "/buildlog"
    @archive  = recipe_path + ".build_results.tar.xz"
    @buildsystem = system
    @ip = system.get_ip
    @port = system.get_port
    @kiwi = "/usr/sbin/kiwi"
  end

  def build
    prepare_build
    Logger.info "Building..."
    build_opts = "--build /vagrant -d /tmp/image --logfile /buildlog"
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo #{@kiwi} #{build_opts}"
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Build failed"
      get_buildlog
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Build failed in kiwi --build for details check: #{@buildlog}"
      )
    end
  end

  def bundle
    Logger.info "Bundle results..."
    bundle_opts = "--bundle-build /tmp/image --bundle-id DiceBuild " +
      "--destdir /tmp/bundle --logfile /buildlog"
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo #{@kiwi} #{bundle_opts}"
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Bundler failed"
      get_buildlog
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Build failed in kiwi --bundle-build for details check: #{@buildlog}"
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
        "sudo tar --exclude image-root -C /tmp/bundle -cJ .",
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
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
        "sudo rm -rf /tmp/image /tmp/bundle; sudo touch /buildlog"
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
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", @port,
        "-i", @job_ssh_private_key, "#{@job_user}@#{@ip}",
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
