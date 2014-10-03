class String
  # colorization
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

  def self.info(message)
    message.gsub!(/\n/,"\n[#{$$}]: ")
    STDOUT.puts "[#{$$}]: #{message}"
  end

  def self.command(*message)
    if @@DEBUG
      puts "[#{$$}]: EXEC: #{message}"
    end
  end

  def self.error(*message)
    message.each do |line|
      line.gsub!(/\n/,"\n[#{$$}]: ")
      STDERR.puts "[#{$$}]: #{line}".red
    end
  end

  def self.setup(arguments)
    if arguments.to_s =~ /--debug/
      @@DEBUG = true
    end
  end
end
