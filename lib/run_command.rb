class Command
  class << self
    def run(*args)
      Dice.logger.command(*args)
      Cheetah.run(*args)
    end
  end
end
