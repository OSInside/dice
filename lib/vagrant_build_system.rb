class VagrantBuildSystem < BuildSystemBase
  attr_reader :recipe, :ssh_output

  def initialize(recipe)
    super(recipe)
    @recipe = recipe
  end

  def get_lockfile
    # set a recipe specific lock
    # building the same recipe multiple times is possible if the
    # buildsystem is a container or a vm but not useful. Thus we
    # prevent that by a recipe lock
    lock = recipe.basepath + "/" + Dice::META + "/" + Dice::LOCK
    lock
  end

  def up
    Dice.logger.info(
      "#{self.class}: Starting up buildsystem for #{recipe.basepath}..."
    )
    begin
      up_output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up virtual system failed with: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: Receiving Host IP/Port information...")
    begin
      @ssh_output = Command.run(
        "vagrant", "ssh", "--debug", "-c", "/bin/true", :stderr => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Retrieving IP/Port information failed: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: #{up_output}")
  end

  def provision
    Dice.logger.info("#{self.class}: Provision build system...")
    begin
      provision_output = Command.run(
        "vagrant", "provision", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Provisioning failed")
      halt
      raise Dice::Errors::VagrantProvisionFailed.new(
        "Provisioning virtual system failed with: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: #{provision_output}")
  end

  def halt
    Dice.logger.info("#{self.class}: Initiate shutdown...")
    begin
      halt_output = Command.run("vagrant", "halt", "-f", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.error(
        "#{self.class}: System stop failed with: #{e.stderr}"
      )
    end
    Dice.logger.info("#{self.class}: #{halt_output}")
    @recipe.reset_working_dir
  end

  def get_port
    port = nil
    if ssh_output =~ /Executing SSH.*\-p.*\"(\d+)\".*/
      port = $1
    else
      if ssh_output.to_s.empty?
        @ssh_output = "<empty-output>"
      end
      raise Dice::Errors::GetPortFailed.new(
        "Port retrieval failed no match in ssh output: #{ssh_output}"
      )
    end
    port
  end

  def get_ip
    ip = nil
    if ssh_output =~ /Executing SSH.*@(.*?)\".*/
      ip = $1
    else
      if ssh_output.to_s.empty?
        @ssh_output = "<empty-output>"
      end
      raise Dice::Errors::GetIPFailed.new(
        "IP retrieval failed no match in ssh output: #{ssh_output}"
      )
    end
    ip
  end

  def get_private_key_path
    pkey = nil
    if ssh_output =~ /Executing SSH.*\-i.*\"(\/.*?)\".*/
      pkey = $1
    else
      if ssh_output.to_s.empty?
        @ssh_output = "<empty-output>"
      end
      raise Dice::Errors::GetSSHPrivateKeyPathFailed.new(
        "SSH private key retrieval failed no match in ssh output: #{ssh_output}"
      )
    end
    pkey
  end

  def is_busy?
    # vagrant VM is never busy, because started by us
    false
  end
end
