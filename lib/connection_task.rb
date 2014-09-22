class ConnectionTask
  def initialize(recipe)
    Recipe.ok?(recipe)
    @factory = ConnectionFactory.new(recipe)
  end

  def log
    @factory.connection.get_log
  end
end
