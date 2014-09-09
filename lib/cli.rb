class Cli
  extend GLI::App

  program_desc 'A builder for kiwi images using vagrant'
  preserve_argv(true)
  @version = Dice::VERSION
  switch :version, :negatable => false, :desc => "Show version"
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
      STDERR.puts e.message
      exit 1
    when SystemExit
      raise
    when SignalException
      STDERR.puts "dice was aborted with signal #{e.signo}"
      exit 1
    else
      STDERR.puts "dice unexpected error"
      result = ""
      if e.backtrace && !e.backtrace.empty?
        result << "Backtrace:\n"
        result << "#{e.backtrace.join("\n")}\n\n"
      end
      STDERR.puts result
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
    c.action do |global_options,options,args|
      recipe = shift_arg(args, "RECIPE-PATH")
      task = BuildTask.new(recipe)
      if task.build?
        task.run
      end
    end
  end
end
