class Command
  def self.run(*args)
    Dice.logger.command(*args)
    Cheetah.run(*args)
  end
end
