class Cli
  extend GLI::App

  program_desc 'A containment build system for kiwi'
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
      Dice.logger.error(e.message)
      @task.buildsystem.release_lock if @task
      exit 1
    when SystemExit
      raise
    when SignalException
      Dice.logger.error("dice was aborted with signal #{e.signo}")
      @task.cleanup if @task
      exit 1
    else
      result = "dice unexpected error: #{e.message}"
      Dice.logger.error(result)
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
      Dice.setup_options(options)
      dir = shift_arg(args, "RECIPE-DIR")
      dir_list = BuildScheduler.description_list(dir)
      dir_list.each do |description|
        Dice.logger.info("Checking dice recipe in: #{description}")
        recipe = Recipe.new(description)
        recipe.validate
      end
      BuildScheduler.run_tasks(dir_list)
    end
  end

  desc "Build from recipe"
  long_desc <<-LONGDESC
    Build image from a given recipe and store the result in a tarball
    with the extension <recipe-path>/.dice/build_results.tar. A recipe
    is a kiwi image description extended by a containment configuration
    stored in a Vagrantfile and/or Dicefile
  LONGDESC
  arg "RECIPE-PATH"
  command :build do |c|
    c.switch ["force", :f], :required => false, :negatable => false,
      :desc => "Force building even if status is up to data"
    c.action do |global_options,options,args|
      Dice.setup_options(options)
      description = shift_arg(args, "RECIPE-PATH")
      recipe = Recipe.new(description)
      recipe.validate
      recipe.setup
      Dice.logger.recipe = recipe
      buildsystem = BuildSystem.new(recipe)
      @task = BuildTask.new(buildsystem)
      @task.run
    end
  end

  desc "Print build log from current build"
  long_desc <<-LONGDESC
    Print build log using a tail command. The command blocks the
    running terminal printing the log information if present
  LONGDESC
  arg "RECIPE-PATH"
  command :buildlog do |c|
    c.switch ["show", :s], :required => false, :negatable => false,
      :desc => "Just show the log if present, skip test for build process"
    c.action do |global_options,options,args|
      Dice.setup_options(options)
      description = shift_arg(args, "RECIPE-PATH")
      recipe = Recipe.new(description)
      recipe.validate
      recipe.setup
      Dice.logger.recipe = recipe
      connection = ConnectionTask.new(recipe)
      connection.log
    end
  end

  desc "Print dice caller history"
  long_desc <<-LONGDESC
    Print history of dice commands and its results for the
    given recipe
  LONGDESC
  arg "RECIPE-PATH"
  command :history do |c|
    c.action do |global_options,options,args|
      Dice.setup_options(options)
      description = shift_arg(args, "RECIPE-PATH")
      recipe = Recipe.new(description)
      recipe.validate
      Dice.logger.recipe = recipe
      Dice.logger.filelog = false
      Dice.logger.history
    end
  end

  desc "Print recipe status"
  long_desc <<-LONGDESC
    Print status information about the given recipe. The status
    provides information whether a rebuild of the recipe is needed
    or a build job is currently running.
  LONGDESC
  arg "RECIPE-PATH"
  command :status do |c|
    c.action do |global_options,options,args|
      Dice.setup_options(options)
      description = shift_arg(args, "RECIPE-PATH")
      recipe = Recipe.new(description)
      recipe.validate
      recipe.setup
      Dice.logger.recipe = recipe
      buildsystem = BuildSystem.new(recipe)
      task = BuildTask.new(buildsystem)
      status = task.build_status
      status.message(recipe)
    end
  end

  desc "ssh into build worker"
  long_desc <<-LONGDESC
    ssh into the build worker. Use this to inspect and debug.
  LONGDESC
  arg "RECIPE-PATH"
  command :ssh do |c|
    c.action do |global_options,options,args|
      Dice.setup_options(options)
      description = shift_arg(args, "RECIPE-PATH")
      recipe = Recipe.new(description)
      recipe.validate
      recipe.setup
      Dice.logger.recipe = recipe
      connection = ConnectionTask.new(recipe)
      connection.ssh
    end
  end
end
