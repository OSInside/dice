class ConnectionTask
  attr_reader :factory

  def initialize(recipe)
    @factory = ConnectionFactory.new(recipe)
  end

  def log
    if Dice.option.show
      factory.print_log
    else
      factory.get_log
    end
  end

  def ssh
    factory.ssh
  end
end
