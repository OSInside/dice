class ConnectionTask
  attr_reader :connection

  def initialize(recipe)
    @connection = Connection.new(recipe)
  end

  def log
    if Dice.option.show
      connection.print_log
    else
      connection.get_log
    end
  end

  def ssh
    connection.ssh
  end
end
