class Command
  def self.run(*args)
    Logger.command(*args)
    Cheetah.run(*args)
  end
end
