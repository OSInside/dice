class BuildSystem < Recipe
  def initialize(description)
    super(description)
  end

  def up
    basepath = get_basepath
    puts "Starting up buildsystem for #{basepath}..."
    begin
      output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up system failed with: #{e.stderr}"
      )
    end
    puts output
  end

  def provision
    puts "Provision build system..."
    begin
      output = Command.run("vagrant", "provision", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      puts "Provisioning failed"
      halt
      raise Dice::Errors::VagrantProvisionFailed.new(
        "Provisioning system failed with: #{e.stderr}"
      )
    end
    puts output
  end

  def halt
    puts "Initiate shutdown..."
    begin
      output = Command.run("vagrant", "halt", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantHaltFailed.new(
        "Stopping system failed with: #{e.stderr}"
      )
    end
    puts output
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
end
