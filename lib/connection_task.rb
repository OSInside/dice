class ConnectionTask
  def initialize(recipe, options = Hash.new)
    @factory = ConnectionFactory.new(recipe)
    @options = options
  end

  def log
    if @options["show"]
      @factory.print_log
    else
      @factory.get_log
    end
  end

  def ssh
    @factory.ssh
  end
end
