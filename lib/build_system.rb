class BuildSystem < Recipe
  def initialize(description)
    super(description)
    change_working_dir
    if self.is_a?(HostBuildSystem)
      # set a global lock for the used worker host
      @lock = get_basepath + "/.lock-" + Dice.config.buildhost
    else
      # set a recipe lock
      @lock = get_basepath + "/" + Dice::META + "/" + Dice::LOCK
    end
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
