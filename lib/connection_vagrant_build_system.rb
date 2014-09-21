class ConnectionVagrantBuildSystem < Connection
  def initialize(description)
    super(description)
  end

  def get_log
    begin
      fuser_data = Command.run(
        "vagrant", "ssh", "-c", "sudo fuser /buildlog", :stdout => :capture
      )
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
    exec("vagrant ssh -c 'tail -f /buildlog --pid #{pid}'")
  end
end
