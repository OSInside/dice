class BuildSystem < Recipe
  def initialize(description)
    super(description)
    change_working_dir
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

  def is_locked?
    raise Dice::Errors::MethodNotImplemented.new(
      "is_locked? method not implemented"
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

  def get_log
    raise Dice::Errors::MethodNotImplemented.new(
      "get_log method not implemented"
    )
  end

  def self.strip_fuser_pid(fuser_data)
    kiwi_pid = fuser_data
    if kiwi_pid =~ /(\d+)/
      kiwi_pid = $1
    end
    kiwi_pid
  end
end
