class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @system = system
    ok?
  end

  def build
    prepare_build
    puts "Starting build..."
    build_opts = "--nocolor --build /vagrant -d /image --logfile /buildlog"
    begin
      Command.run("vagrant", "ssh", "-c",
        "sudo /usr/sbin/kiwi #{build_opts} "
      )
    rescue Cheetah::ExecutionFailed => e
      puts "Build failed"
      get_buildlog
      @system.halt
      raise Dice::Errors::BuildFailed.new(
        "Build job failed for details check: #{@buildlog}"
      )
    end
  end

  def extract_result(host, destination)
    # TODO
  end

  private

  def ok?
    @basepath = @system.get_description
    @buildlog = @basepath + "/buildlog"
    if !File.file?(@basepath + "/config.xml")
      raise Dice::Errors::NoKIWIConfig.new(
        "Need a kiwi config.xml"
      )
    end
    Dir.chdir(@basepath)
  end

  def prepare_build
    puts "Preparing build..."
    FileUtils.rm(@buildlog) if File.file?(@buildlog)
    Command.run("vagrant", "ssh", "-c",
      "sudo rm -rf /image; sudo touch /buildlog"
    )
  end

  def get_buildlog
    puts "Retrieving build log..."
    logfile = File.open(@buildlog, "w")
    Command.run("vagrant", "ssh", "-c",
      "sudo cat /buildlog", :stdout => logfile
    )
  end
end
