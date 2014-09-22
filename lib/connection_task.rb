class ConnectionTask
  def initialize(recipe)
    Recipe.ok?(recipe)
    @factory = ConnectionFactory.new(recipe)
    @connection = @factory.connection
  end

  def log
    @connection.get_log
  end
end
