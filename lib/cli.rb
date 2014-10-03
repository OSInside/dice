class Cli
  extend GLI::App

  program_desc 'A builder for kiwi images using vagrant'
  preserve_argv(true)
  @version = Dice::VERSION
  switch :version, :negatable => false, :desc => "Show version"
  switch :debug, :negatable => false, :desc => "Enable debug mode"
  switch [:help, :h], :negatable => false, :desc => "Show help"

  def self.handle_error(e)
    case e
    when GLI::UnknownCommandArgument, GLI::UnknownGlobalArgument,
        GLI::UnknownCommand, GLI::BadCommandLine
      STDERR.puts e.to_s + "\n\n"
      command = ARGV & @commands.keys.map(&:to_s)
      run(command << "--help")
      exit 1
    when Dice::Errors::DiceError
      Logger.error(e.message)
      exit 1
    when SystemExit
      raise
    when SignalException
      Logger.error("dice was aborted with signal #{e.signo}")
      if @task
        @task.cleanup
      end
      exit 1
    else
      Logger.error("dice unexpected error")
      result = ""
      if e.backtrace && !e.backtrace.empty?
        result << "Backtrace:\n"
        result << "#{e.backtrace.join("\n")}\n\n"
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
      @task = BuildTask.new(recipe)
      status = Dice::Status::BuildRequired.new
      # asking for the build_status will lock the buildsystem if
      # it is not already locked. At the end of the build_status
      # call the lock is released by default. If the build status
      # determines that a new build is required we call the run
      # method which also locks the buildsystem. If we don't
      # tell the build_status method to keep the log open we
      # produce a potential lock raise in the time between the
      # end of build_status and the start of run where the
      # buildsystem should be in nonstop in locked state. In order
      # to stay locked we pass keep_locked set to true when
      # build_status is called. The lock is released properly at
      # the end of run or on error
      keep_locked = true
      if !options["force"]
        status = @task.build_status(keep_locked)
      end
      if status.is_a?(Dice::Status::BuildRequired)
        @task.run
      else
        status.message
      end
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
