class BuildSystem < Recipe
  def initialize(description)
    super(description)
    change_working_dir
    @lock = get_basepath + "/" + Dice::META + "/" + Dice::LOCK
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

  def is_locked?
    raise Dice::Errors::MethodNotImplemented.new(
      "is_locked? method not implemented"
    )
  end

  def is_busy?
    raise Dice::Errors::MethodNotImplemented.new(
      "is_busy? method not implemented"
    )
  end

  def set_lock
    lockfile = File.new(@lock, "w")
    lockfile.close
  end

  def release_lock
    FileUtils.rm(@lock) if File.file?(@lock)
  end
end
