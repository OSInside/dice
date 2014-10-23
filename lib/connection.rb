class Connection
  abstract_method :ssh

  def initialize(recipe)
    recipe.change_working_dir
    @build_log = recipe.get_basepath + "/" + Dice::META + "/" + Dice::BUILD_LOG
  end

  def get_log
    begin
      fuser_data = Command.run("fuser", @build_log, :stdout => :capture)
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
    exec("tail -f #{@build_log} --pid #{pid}")
  end

  def print_log
    begin
      puts File.read(@build_log)
    rescue => e
      raise Dice::Errors::NoLogFile.new(
        "Logfile not available: #{e}"
      )
    end
  end

  def self.strip_fuser_pid(fuser_data)
    kiwi_pid = fuser_data
    if kiwi_pid =~ /(\d+)/
      kiwi_pid = $1
    end
    kiwi_pid
  end
end
