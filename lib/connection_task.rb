class ConnectionTask
  def initialize(recipe, options = Hash.new)
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

  def ssh
    @factory.connection.ssh
  end
end
