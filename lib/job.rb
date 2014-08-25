class Job
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @system = system
    @job_id = 1
    ok?
  end

  def build
    puts "Starting build..."
    @job_id++
    begin
      output = Command.run("vagrant", "ssh", "-c",
        "sudo /usr/sbin/kiwi --nocolor --build /vagrant -d /image", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      @system.halt
      raise Dice::Errors::BuildFailed.new(
        "Build job failed with: #{e.stderr}"
      )
    end
    puts output
  end

  def bundle_result
    puts "Bundle result..."
    begin
      output = Command.run("vagrant", "ssh", "-c",
        "sudo /usr/sbin/kiwi --nocolor --bundle-build /image --bundle-id #{@job_id} -d /build_result", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      @system.halt
      raise Dice::Errors::BundleBuildFailed.new(
        "Bundle result failed with: #{e.stderr}"
      )
    end
    puts output
  end

  def extract_result(host, destination)
    # TODO
  end

  private

  def ok?
    @basepath = @system.get_description
    if !File.file?(@basepath + "/config.xml")
      raise Dice::Errors::NoKIWIConfig.new(
        "Need a kiwi config.xml"
      )
    end
    Dir.chdir(@basepath)
  end
end
