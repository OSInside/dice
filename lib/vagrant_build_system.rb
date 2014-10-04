class VagrantBuildSystem < BuildSystem
  def initialize(description)
    super(description)
  end

  def up
    basepath = get_basepath
    Logger.info "Starting up buildsystem for #{basepath}..."
    begin
      @up_output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up vritual system failed with: #{e.stderr}"
      )
    end
    Logger.info @up_output
  end

  def provision
    Logger.info "Provision build system..."
    begin
      provision_output = Command.run(
        "vagrant", "provision", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      Logger.info "Provisioning failed"
      halt
      raise Dice::Errors::VagrantProvisionFailed.new(
        "Provisioning virtual system failed with: #{e.stderr}"
      )
    end
    Logger.info provision_output
  end

  def halt
    Logger.info "Initiate shutdown..."
    begin
      halt_output = Command.run("vagrant", "halt", "-f", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantHaltFailed.new(
        "System stop failed with: #{e.stderr}"
      )
    end
    Logger.info halt_output
    reset_working_dir
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
end
