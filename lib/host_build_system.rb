class HostBuildSystem < BuildSystem
  def initialize(description)
    super(description)
    @host = Dice.config.buildhost
    @user = Dice.config.ssh_user
    @ssh_private_key = Dice.config.ssh_private_key
    @basepath = get_basepath
  end

  def up
    Logger.info "Using buildsystem #{@host} for #{@basepath}..."
  end

  def provision
    Logger.info "Provision build system..."
    begin
      provision_output = Command.run(
        "rsync", "-e", "ssh -i #{@ssh_private_key}", "-z", "-a", "-v",
        "--exclude", ".*", ".", "#{@user}@#{@host}:/vagrant",
        :stdout => :capture
      )
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
    lock_status = true
    begin
      Command.run(
        "ssh", "-i", @ssh_private_key, "#{@user}@#{@host}",
        "pidof -x kiwi"
      )
    rescue Cheetah::ExecutionFailed
      lock_status = false
    end
    lock_status
  end

  def get_port
    port = "22"
    port
  end

  def get_ip
    @host
  end
end
