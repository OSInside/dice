class ConnectionTask
  def initialize(recipe, options = Hash.new)
    Recipe.ok?(recipe)
    @factory = ConnectionFactory.new(recipe)
    @options = options
  end

  def log
    if @options["show"]
      @factory.connection.print_log
    else
      @factory.connection.get_log
    end
  end
end
