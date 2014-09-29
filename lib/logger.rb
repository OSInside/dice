class Logger
  @@DEBUG = false

  def self.info(message)
    puts "[#{$$}]: #{message}"
  end

  def self.command(*message)
    if @@DEBUG
      puts "[#{$$}]: EXEC: #{message}"
    end
  end

  def self.error(*message)
    message.each do |line|
      line.gsub!(/\n/,"\n[#{$$}]: ")
      STDERR.print "[#{$$}]: #{line}"
    end
    STDERR.puts "Exception raised"
  end

  def self.setup(arguments)
    if arguments.to_s =~ /--debug/
      @@DEBUG = true
    end
  end
end
