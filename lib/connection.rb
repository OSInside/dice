class Connection < Recipe
  def initialize(description)
    super(description)
    change_working_dir
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
