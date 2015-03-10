class ConnectionBase
  attr_reader :build_log, :recipe

  abstract_method :ssh

  def initialize(recipe)
    @recipe = recipe
    @build_log = recipe.basepath + "/" + Dice::META + "/" + Dice::BUILD_LOG
    recipe.change_working_dir
    post_initialize
  end

  def post_initialize
    nil
  end

  def get_log
    begin
      fuser_data = Command.run("fuser", build_log, :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      details = e.stderr
      if details == ""
        details = "No build process writing to logfile"
      end
      raise Dice::Errors::NoLogFile.new(
        "Logfile not available: #{details}"
      )
    end
    pid = strip_fuser_pid(fuser_data)
    exec("tail -f #{build_log} --pid #{pid}")
  end

  def print_log
    begin
      puts File.read(build_log)
    rescue => e
      raise Dice::Errors::NoLogFile.new(
        "Logfile not available: #{e}"
      )
    end
  end

  private

  def strip_fuser_pid(fuser_data)
    kiwi_pid = fuser_data
    if kiwi_pid =~ /(\d+)/
      kiwi_pid = $1
    end
    kiwi_pid
  end
end
