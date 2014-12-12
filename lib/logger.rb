class Logger
  attr_accessor :debug, :recipe, :log, :filelog
  attr_reader :time

  def initialize
    @time = Time.now.utc.iso8601
    @debug = false
    @recipe = nil
    @log = nil
    @filelog = true
  end

  def info(message)
    prefix_multiline(message)
    STDOUT.puts "#{prefix}: #{message}"
    append_to_logfile(message) if filelog
  end

  def command(*message)
    if debug
      msg = "#{prefix}: EXEC: [#{message.join(" ")}]"
      STDOUT.puts msg
      append_to_logfile(msg) if filelog
    end
  end

  def error(message)
    prefix_multiline(message)
    STDERR.puts "#{prefix}: #{message}".red
    append_to_logfile(message) if filelog
  end

  private

  def prefix_multiline(message)
    message.gsub!(/\n/,"\n#{prefix}: ")
    message
  end

  def append_to_logfile(message)
    open_logfile unless log
    return if !log
    log[time]["message"] += "\n" + message
    log.write
  end

  def open_logfile
    return if !recipe
    logfile = recipe.basepath + "/" + Dice::META + "/" + Dice::BUILD_LOG
    FileUtils.mkdir_p File.dirname(logfile)
    begin
      self.log = IniFile.load(:filename => logfile)
    rescue
      self.log = IniFile.new(:filename => logfile)
    end
    log[time] = {
      "cmdline" => "$ dice #{ARGV.join(" ")}",
      "message" => ""
    }
    log.write
  end

  def prefix
    if recipe
      prefix = "[#{$$}][#{File.basename(recipe.basepath)}]"
    else
      prefix = "[#{$$}]"
    end
    prefix
  end
end
