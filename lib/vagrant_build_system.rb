class VagrantBuildSystem < BuildSystem
  def initialize(recipe)
    super(recipe)
    @recipe = recipe
  end

  def up
    Logger.info("#{self.class}: Starting up buildsystem for #{@recipe.get_basepath}...")
    begin
      @up_output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up vritual system failed with: #{e.stderr}"
      )
    end
    Logger.info("#{self.class}: #{@up_output}")
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
    if @up_output =~ /--.*=> (\d+).*/
      port = $1
    else
      if !@up_output
        @up_output = "<empty-output>"
      end
      raise Dice::Errors::GetPortFailed.new(
        "Port retrieval failed no match in startup output: #{@up_output}"
      )
    end
    port
  end

  def get_ip
    ip = "127.0.0.1"
    ip
  end

  def is_busy?
    # vagrant VM is never busy, because started by us
    false
  end
end
