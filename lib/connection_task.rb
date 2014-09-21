class ConnectionTask
  def initialize(recipe)
    Recipe.ok?(recipe)
    @connection = ConnectionFactory.from_recipe(recipe)
  end

  def log
    @connection.get_log
  end
end
