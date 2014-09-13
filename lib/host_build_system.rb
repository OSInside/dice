class HostBuildSystem < BuildSystem
  def initialize(description)
    super(description)
    @host = Dice.config.buildhost
  end

  def up
    basepath = get_basepath
    Logger.info "Using buildsystem #{@host} for #{basepath}..."
  end

  def provision
    Logger.info "Provision build system..."
    begin
      # TODO: rsync recipe to build system
      provision_output = Command.run("false")
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Provisioning failed"
      halt
      raise Dice::Errors::HostProvisionFailed.new(
        "Provisioning system failed with: #{e.stderr}"
      )
    end
    Logger.info provision_output
  end

  def halt
    reset_working_dir
  end

  def is_locked?
    lock_status = false
    begin
      #TODO: check if a kiwi process runs there
      output = Command.run( "false" )
    rescue Cheetah::ExecutionFailed
      # continue, handle as not locked
    end
    if output =~ /running/
      lock_status = true
    end
    lock_status
  end

  def get_port
    port = 22
    port
  end

  def get_ip
    @host
  end
end
