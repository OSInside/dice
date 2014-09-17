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
        "Starting up system failed with: #{e.stderr}"
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
        "Provisioning system failed with: #{e.stderr}"
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
        "Stopping system failed with: #{e.stderr}"
      )
    end
    Logger.info halt_output
    reset_working_dir
  end

  def is_locked?
    lock_status = false
    begin
      output = Command.run("vagrant", "status", :stdout => :capture)
    rescue Cheetah::ExecutionFailed
      # continue, handle as not locked
    end
    if output =~ /running/
      lock_status = true
    end
    lock_status
  end

  def get_port
    port = nil
    if @up_output =~ /--.*=> (\d+).*/
      port = $1
    else
      raise Dice::Errors::GetPortFailed.new(
        "Port retrieval failed, no match in machine up output: #{@up_output}"
      )
    end
    port
  end

  def get_ip
    ip = "127.0.0.1"
    ip
  end

  def get_log
    begin
      kiwi_pid = Command.run(
        "vagrant", "ssh", "-c", "sudo fuser /buildlog", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      details = e.stderr
      if details == ""
        details = "No build process writing to logfile"
      end
      raise Dice::Errors::NoLogFile.new(
        "Logfile not available: #{details}"
      )
    end
    exec("vagrant ssh -c 'tail -f /buildlog --pid #{kiwi_pid}'")
  end
end
