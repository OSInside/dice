class VagrantBuildSystem < BuildSystem
  def initialize(recipe)
    super(recipe)
    @recipe = recipe
  end

  def up
    Logger.info(
      "#{self.class}: Starting up buildsystem for #{@recipe.get_basepath}..."
    )
    begin
      up_output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up virtual system failed with: #{e.stderr}"
      )
    end
    Logger.info("#{self.class}: Receiving Host IP/Port information...")
    begin
      @ssh_output = Command.run(
        "vagrant", "ssh", "--debug", "-c", "/bin/true", :stderr => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Retrieving IP/Port information failed: #{e.stderr}"
      )
    end
    Logger.info("#{self.class}: #{up_output}")
  end

  def provision
    Logger.info("#{self.class}: Provision build system...")
    begin
      provision_output = Command.run(
        "vagrant", "provision", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info("#{self.class}: Provisioning failed")
      halt
      raise Dice::Errors::VagrantProvisionFailed.new(
        "Provisioning virtual system failed with: #{e.stderr}"
      )
    end
    Logger.info("#{self.class}: #{provision_output}")
  end

  def halt
    Logger.info("#{self.class}: Initiate shutdown...")
    begin
      halt_output = Command.run("vagrant", "halt", "-f", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantHaltFailed.new(
        "System stop failed with: #{e.stderr}"
      )
    end
    Logger.info("#{self.class}: #{halt_output}")
    @recipe.reset_working_dir
  end

  def get_port
    port = nil
    if @ssh_output =~ /Executing SSH.*\-p.*\"(\d+)\".*/
      port = $1
    else
      if !@ssh_output
        @ssh_output = "<empty-output>"
      end
      raise Dice::Errors::GetPortFailed.new(
        "Port retrieval failed no match in ssh output: #{@ssh_output}"
      )
    end
    port
  end

  def get_ip
    ip = nil
    if @ssh_output =~ /Executing SSH.*@(.*?)\".*/
      ip = $1
    else
      if !@ssh_output
        @ssh_output = "<empty-output>"
      end
      raise Dice::Errors::GetPortFailed.new(
        "IP retrieval failed no match in ssh output: #{@ssh_output}"
      )
    end
    ip
  end

  def is_busy?
    # vagrant VM is never busy, because started by us
    false
  end
end
