class HostBuildSystem < BuildSystem
  attr_reader :recipe, :host, :user, :ssh_private_key, :basepath

  def initialize(recipe)
    super(recipe)
    @recipe = recipe
    @host = Dice.config.buildhost
    @user = Dice.config.ssh_user
    @ssh_private_key = Dice.config.ssh_private_key
    @basepath = @recipe.basepath
  end

  def up
    Logger.info("#{self.class}: Using buildsystem #{host} for #{basepath}...")
    if is_busy?
      raise Dice::Errors::BuildWorkerBusy.new(
        "Buildsystem #{host} is busy with other build process"
      )
    end
  end

  def provision
    Logger.info("#{self.class}: Provision build system...")
    begin
      ssh_options = "-o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0"
      provision_output = Command.run(
        "rsync", "-e",
        "ssh #{ssh_options} -i #{ssh_private_key}",
        "--rsync-path", "sudo rsync", "-z", "-a", "-v", "--delete",
        "--exclude", ".*", ".", "#{user}@#{host}:/vagrant",
        :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info("#{self.class}: Provisioning failed")
      halt
      raise Dice::Errors::HostProvisionFailed.new(
        "Provisioning system failed with: #{e.stderr}"
      )
    end
    Logger.info("#{self.class}: #{provision_output}")
  end

  def halt
    Logger.info("#{self.class}: Stopping build process on #{host}...")
    begin
      Command.run(
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-o", "NumberOfPasswordPrompts=0",
        "-i", ssh_private_key, "#{user}@#{host}",
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

  def is_busy?
    busy = true
    begin
      Command.run(
        "ssh",
        "-o", "StrictHostKeyChecking=no",
        "-o", "NumberOfPasswordPrompts=0",
        "-i", ssh_private_key, "#{user}@#{host}",
        "sudo", "pidof", "-x", "kiwi"
      )
    rescue Cheetah::ExecutionFailed => e
      busy = false
    end
    busy
  end
end
