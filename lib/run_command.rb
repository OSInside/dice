class Command
  class << self
    def run(*args)
      Dice.logger.command(*args)
      Cheetah.run(*args)
    end

    def exists?(name)
      begin
        run("which", name)
      rescue
        return false
      end
      true
    end
  end
end
