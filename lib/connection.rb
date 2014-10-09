class Connection < Recipe
  def initialize(description)
    super(description)
    change_working_dir
  end

  def get_log
    error_log = get_basepath + "/" + Dice::META + "/" + Dice::BUILD_ERROR_LOG
    begin
      fuser_data = Command.run("fuser", error_log, :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      details = e.stderr
      if details == ""
        details = "No build process writing to logfile"
      end
      raise Dice::Errors::NoLogFile.new(
        "Logfile not available: #{details}"
      )
    end
    pid = Connection.strip_fuser_pid(fuser_data)
    exec("tail -f #{error_log} --pid #{pid}")
  end

  def self.strip_fuser_pid(fuser_data)
    kiwi_pid = fuser_data
    if kiwi_pid =~ /(\d+)/
      kiwi_pid = $1
    end
    kiwi_pid
  end
end
