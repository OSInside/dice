class String
  # colorization of strings
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def col(id)
    colorize(id)
  end
end

class Logger
  @@DEBUG = false
  @@RECIPE_DIR = "unknown-recipe"

  def self.info(message)
    message.gsub!(/\n/,"\n#{prefix}: ")
    STDOUT.puts "#{prefix}: #{message}"
  end

  def self.command(*message)
    if @@DEBUG
      puts "#{prefix}: EXEC: [#{message.join(" ")}]"
    end
  end

  def self.error(message, logfile = nil)
    if logfile
      FileUtils.mkdir_p File.dirname(logfile)
      error_log = File.new(logfile, "a")
      error_log.puts "$ dice #{ARGV.join(" ")}\n"
      error_log.puts message
      error_log.close
    end
    message.gsub!(/\n/,"\n#{prefix}: ")
    STDERR.puts "#{prefix}: #{message}".red
  end

  def self.setup(arguments)
    if arguments.to_s =~ /--debug/
      @@DEBUG = true
    end
  end

  def self.set_recipe_dir(dir)
    @@RECIPE_DIR = dir
  end

  private

  def self.prefix
    prefix = "[#{$$}][#{@@RECIPE_DIR}]"
    prefix
  end
end
