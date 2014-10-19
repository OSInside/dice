class ConnectionTask
  def initialize(description, options = Hash.new)
    Recipe.ok?(description)
    @factory = ConnectionFactory.new(description)
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
