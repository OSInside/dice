class HostBuildSystem < BuildSystemBase
  attr_reader :host, :user

  def post_initialize
    @host = Dice.config.buildhost
    @user = Dice.config.ssh_user
  end

  def get_lockfile
    # set a global lock for the used worker host
    # running multiple builds in parallel on one host is not supported
    # by kiwi. Thus we set a lock for the entire host
    lock = "/tmp/.lock-" + Dice.config.buildhost
    lock
  end

  def up
    Dice.logger.info(
      "#{self.class}: Using buildsystem #{host} for #{recipe.basepath}..."
    )
    if is_busy?
      raise Dice::Errors::BuildWorkerBusy.new(
        "Buildsystem #{host} is busy with other build process"
      )
    end
  end

  def provision
    Dice.logger.info("#{self.class}: Provision build system...")
    begin
      ssh_options = "-o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0"
      provision_output = Command.run(
        "rsync", "-e",
        "ssh #{ssh_options} -i #{get_private_key_path}",
        "--rsync-path", "sudo rsync", "-z", "-a", "-v", "--delete",
        "--exclude", ".*", ".", "#{user}@#{host}:/vagrant",
        :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Provisioning failed")
      halt
      raise Dice::Errors::HostProvisionFailed.new(
        "Provisioning system failed with: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: #{provision_output}")
  end

  def halt
    Dice.logger.info("#{self.class}: Stopping build process on #{host}...")
    begin
      Command.run(
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-o", "NumberOfPasswordPrompts=0",
        "-i", get_private_key_path, "#{user}@#{host}",
        "sudo", "killall", "kiwi"
      )
    rescue Cheetah::ExecutionFailed => e
      # continue even if there was no process to kill
    end
    recipe.reset_working_dir
  end

  def get_port
    port = "22"
    port
  end

  def get_ip
    host
  end

  def get_private_key_path
    Dice.config.ssh_private_key
  end

  def is_busy?
    busy = true
    begin
      Command.run(
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-o", "NumberOfPasswordPrompts=0",
        "-i", get_private_key_path, "#{user}@#{host}",
        "sudo", "pidof", "-x", "kiwi"
      )
    rescue Cheetah::ExecutionFailed => e
      busy = false
    end
    busy
  end
end
