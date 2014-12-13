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

  def history
    logfile = recipe.basepath + "/" + Dice::META + "/" + Dice::HISTORY
    if !File.exists?(logfile)
      raise Dice::Errors::NoBuildHistory.new(
        "No history available"
      )
    end
    print_history(logfile)
  end

  private

  def print_history(logfile)
    inilog = IniFile.new
    inilog.filename = logfile
    inilog.read
    inilog.sections.each do |section|
      message_lines = inilog[section]["message"].split(/\n/)
      puts "[ #{section} ]".green
      puts "  cmdline => #{inilog[section]["cmdline"]}"
      puts "  message => ["
      message_lines.each do |line|
        puts "    #{line}"
      end
      puts "  ]"
    end
  end

  def prefix_multiline(message)
    message.gsub!(/\n/,"\n#{prefix}: ")
    message
  end

  def append_to_logfile(message)
    open_logfile unless log
    return if !log
    log[time]["message"] += message + "\n"
    log.write
  end

  def open_logfile
    return if !recipe
    logfile = recipe.basepath + "/" + Dice::META + "/" + Dice::HISTORY
    FileUtils.mkdir_p File.dirname(logfile)
    inilog = IniFile.new
    begin
      inilog.filename = logfile
      inilog.read
    rescue
      # ignore if file could not be loaded and start
      # logging from scratch
    end
    self.log = inilog
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
