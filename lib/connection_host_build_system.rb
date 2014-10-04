class ConnectionHostBuildSystem < Connection
  def initialize(description)
    super(description)
    @host = Dice.config.buildhost
    @user = Dice.config.ssh_user
    @ssh_private_key = Dice.config.ssh_private_key
  end

  def get_log
    begin
      fuser_data = Command.run(
        "ssh", "-i", @ssh_private_key, "#{@user}@#{@host}",
        "sudo", "fuser", "/buildlog", :stdout => :capture
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
    ssh = "ssh -i #{@ssh_private_key} #{@user}@#{@host}"
    exec("#{ssh} tail -f /buildlog --pid #{pid}")
  end
end
