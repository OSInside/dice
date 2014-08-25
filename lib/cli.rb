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
      STDERR.puts e.message
      exit 1
    end
    true
  end

  on_error do |e|
    Cli.handle_error(e)
  end
end
