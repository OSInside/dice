class Cli
  extend GLI::App

  program_desc 'A builder for kiwi images using vagrant'
  preserve_argv(true)
  @version = Dice::VERSION
  switch :version, :negatable => false, :desc => "Show version"
  switch :debug, :negatable => false, :desc => "Enable debug mode"
  switch [:help, :h], :negatable => false, :desc => "Show help"

  def self.error_log_file
    log_file = nil
    log_file = @task.error_log_file if @task
    log_file
  end

  def self.handle_error(e)
    case e
    when GLI::UnknownCommandArgument, GLI::UnknownGlobalArgument,
        GLI::UnknownCommand, GLI::BadCommandLine
      STDERR.puts e.to_s + "\n\n"
      command = ARGV & @commands.keys.map(&:to_s)
      run(command << "--help")
      exit 1
    when Dice::Errors::DiceError
      Logger.error(e.message, error_log_file)
      @task.release_lock if @task
      exit 1
    when SystemExit
      raise
    when SignalException
      Logger.error(
        "dice was aborted with signal #{e.signo}", error_log_file
      )
      @task.cleanup if @task
      exit 1
    else
      result = "dice unexpected error"
      if e.backtrace && !e.backtrace.empty?
        result += "\nBacktrace:\n"
        result += "#{e.backtrace.join("\n")}\n\n"
      end
      Logger.error(result)
      exit 1
    end
    true
  end

  on_error do |e|
    Cli.handle_error(e)
  end

  def self.shift_arg(args, name)
    if !res = args.shift
      raise GLI::BadCommandLine.new(
        "dice was called with missing argument #{name}."
      )
    end
    res
  end

  desc "Schedule build tasks from recipe directory"
  long_desc <<-LONGDESC
    Start a build task for each recipe found in the given directory.
    Each task runs in an independent thread. In case of an error or
    a blocked build system the build task is not repeated automatically.
    It's possible to reschedule the build tasks by placing the call
    into a cronjob
  LONGDESC
  arg "RECIPE-DIR"
  command :schedule do |c|
    c.action do |global_options,options,args|
      dir = shift_arg(args, "RECIPE-DIR")
      BuildScheduler.run_tasks(dir)
    end
  end

  desc "Build from recipe"
  long_desc <<-LONGDESC
    Build image from a given recipe and store the result in a tarball
    with the extension <recipe-path>.build_results.tar. A recipe is a
    kiwi image description extended by a Vagrantfile
  LONGDESC
  arg "RECIPE-PATH"
  command :build do |c|
    c.switch ["force", :f], :required => false, :negatable => false,
      :desc => "Force building even if status is up to data"
    c.action do |global_options,options,args|
      recipe = shift_arg(args, "RECIPE-PATH")
      @task = BuildTask.new(recipe, options)
      @task.run
    end
  end

  desc "Print log from current build"
  long_desc <<-LONGDESC
    Print build log using a tail command. The command blocks the
    running terminal printing the log information if present
  LONGDESC
  arg "RECIPE-PATH"
  command :log do |c|
    c.action do |global_options,options,args|
      recipe = shift_arg(args, "RECIPE-PATH")
      connection = ConnectionTask.new(recipe)
      connection.log
    end
  end

  desc "Print recipe status"
  long_desc <<-LONGDESC
    Print status information about the given recipe. The status
    provides information whether a rebuild of the recipe is needed
    or a build job is currently running
  LONGDESC
  arg "RECIPE-PATH"
  command :status do |c|
    c.action do |global_options,options,args|
      recipe = shift_arg(args, "RECIPE-PATH")
      task = BuildTask.new(recipe)
      status = task.build_status
      status.message
    end
  end
end
