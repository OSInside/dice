module Dice
  @@logger = nil

  def self.setup_logger(arguments)
    @@logger = Logger.new
    if arguments.to_s =~ /--debug/
      @@logger.debug = true
    end
  end

  def self.logger
    setup_logger(ARGV) unless @@logger
    @@logger
  end
end
