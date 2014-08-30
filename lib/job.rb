class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    recipe_path = system.get_basepath
    @buildlog = recipe_path + "/buildlog"
    @archive  = recipe_path + ".build_results.tar"
    @buildsystem = system
    @ip = system.get_ip
    @port = system.get_port
  end

  def build
    prepare_build
    puts "Starting build..."
    build_opts = "--nocolor --build /vagrant -d /image --logfile /buildlog"
    begin
      Command.run("ssh", "-p", @port, "-i", Dice::VAGRANT_KEY, "vagrant@#{@ip}",
        "sudo /usr/sbin/kiwi #{build_opts} "
      )
    rescue Cheetah::ExecutionFailed => e
      puts "Build failed"
      get_buildlog
      @buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Build job failed for details check: #{@buildlog}"
      )
    end
  end

  def get_result
    puts "Retrieving results in #{@archive}..."
    result = File.open(@archive, "w")
    begin
      Command.run("ssh", "-p", @port, "-i", Dice::VAGRANT_KEY, "vagrant@#{@ip}",
        "sudo tar --exclude image-root -C /image -c .",
        :stdout => result
      )
    rescue Cheetah::ExecutionFailed => e
      puts "Archiving failed"
      @buildsystem.halt
      raise Dice::Errors::ResultRetrievalFailed.new(
        "Archiving results failed with: #{e.stderr}"
      )
    end
  end

  private

  def prepare_build
    puts "Preparing build..."
    FileUtils.rm(@buildlog) if File.file?(@buildlog)
    FileUtils.rm(@archive) if File.file?(@archive)
    begin
      Command.run("ssh", "-p", @port, "-i", Dice::VAGRANT_KEY, "vagrant@#{@ip}",
        "sudo rm -rf /image; sudo touch /buildlog"
      )
    rescue Cheetah::ExecutionFailed => e
      puts "Preparation failed"
      @buildsystem.halt
      raise Dice::Errors::PrepareBuildFailed.new(
        "Prepare build env failed with: #{e.stderr}"
      )
    end
  end

  def get_buildlog
    puts "Retrieving build log..."
    logfile = File.open(@buildlog, "w")
    begin
      Command.run("ssh", "-p", @port, "-i", Dice::VAGRANT_KEY, "vagrant@#{@ip}",
        "sudo cat /buildlog", :stdout => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      puts "Retrieving build log failed"
      @buildsystem.halt
      raise Dice::Errors::LogFileRetrievalFailed.new(
        "Reading log file failed with: #{e.stderr}"
      )
    end
  end
end
