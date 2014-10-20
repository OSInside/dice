class BuildSystem
  def initialize(recipe)
    @recipe = recipe
    @recipe.change_working_dir
    @build_log = @recipe.get_basepath + "/" + Dice::META + "/" + Dice::BUILD_LOG
    if self.is_a?(HostBuildSystem)
      # set a global lock for the used worker host
      @lock = "/tmp/.lock-" + Dice.config.buildhost
    else
      # set a recipe lock
      @lock = @recipe.get_basepath + "/" + Dice::META + "/" + Dice::LOCK
    end
  end

  def recipe
    @recipe
  end

  def up
    raise Dice::Errors::MethodNotImplemented.new(
      "up method not implemented"
    )
  end

  def provision
    raise Dice::Errors::MethodNotImplemented.new(
      "provision method not implemented"
    ) 
  end

  def halt
    raise Dice::Errors::MethodNotImplemented.new(
      "halt method not implemented"
    )
  end

  def get_port
    raise Dice::Errors::MethodNotImplemented.new(
      "get_port method not implemented"
    )
  end

  def get_ip
    raise Dice::Errors::MethodNotImplemented.new(
      "get_ip method not implemented"
    )
  end

  def is_busy?
    raise Dice::Errors::MethodNotImplemented.new(
      "is_busy? method not implemented"
    )
  end

  def is_building?
    building = true
    begin
      Command.run("fuser", @build_log, :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      building = false
    end
    building
  end

  def is_locked?
    File.file?(@lock)
  end

  def set_lock
    lockfile = File.new(@lock, "w")
    lockfile.close
  end

  def release_lock
    FileUtils.rm(@lock) if File.file?(@lock)
  end
end
