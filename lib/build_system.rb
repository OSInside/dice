class BuildSystem
  def initialize(description)
    @recipe = Pathname.new(description)
    ok?
  end

  def up
    puts "Starting up..."
    begin
      output = Command.run("vagrant", "up", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantUpFailed.new(
        "Starting up job from #{@recipe} failed with: #{e}"
      )
    end
    puts output
  end

  def provision
    puts "Provision build system..."
    begin
      output = Command.run("vagrant", "provision", :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::VagrantProvisionFailed.new(
        "Provisioning job from #{@recipe} failed with: #{e}"
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
        "Stopping job from #{@recipe} failed with: #{e}"
      )
    end
    puts output
  end

  def is_locked?
    lock_status = false
    begin
      output = Command.run("vagrant", "status", :stdout => :capture)
    rescue Cheetah::ExecutionFailed
      # continue
    end
    if output =~ /running/
      lock_status = true
    end
    lock_status
  end

  def get_description
    @basepath
  end

  private

  def ok?
    if !File.exists?(@recipe) || !File.directory?(@recipe.realpath)
      raise Dice::Errors::NoDirectory.new(
        "Need a description directory"
      )
    end
    @basepath = @recipe.realpath.to_s
    if !File.file?(@basepath + "/Vagrantfile")
      raise Dice::Errors::NoVagrantFile.new(
        "Need a Vagrantfile"
      )
    end
    Dir.chdir(@basepath)
  end
end
