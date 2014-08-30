class BuildSystem < Recipe
  def initialize(description)
    super(description)
    change_working_dir
  end

  def up
    basepath = get_basepath
    puts "Starting up buildsystem for #{basepath}..."
    begin
      @up_output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up system failed with: #{e.stderr}"
      )
    end
    puts @up_output
  end

  def provision
    puts "Provision build system..."
    begin
      provision_output = Command.run(
        "vagrant", "provision", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      puts "Provisioning failed"
      halt
      raise Dice::Errors::VagrantProvisionFailed.new(
        "Provisioning system failed with: #{e.stderr}"
      )
    end
    puts provision_output
  end

  def halt
    puts "Initiate shutdown..."
    begin
      halt_output = Command.run("vagrant", "halt", "-f", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantHaltFailed.new(
        "Stopping system failed with: #{e.stderr}"
      )
    end
    puts halt_output
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
    port = ""
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
    begin
      ip = Command.run("vagrant", "ssh", "-c",
        "ip -o -4 addr show dev lan0", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      halt
      raise Dice::Errors::GetIPFailed.new(
        "IP retrieval failed with: #{e.stderr}"
      )
    end
    if ip =~ /inet (.*)\//
      ip = $1
    else
      raise Dice::Errors::GetIPFailed.new(
        "IP retrieval failed in match for #{ip}"
      )
    end
  end
end
