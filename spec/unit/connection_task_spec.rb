require_relative "spec_helper"

describe ConnectionTask do
  before(:each) do
    @factory = double(ConnectionFactory)
    @connection = double(Connection)
    expect(Recipe).to receive(:ok?)
    expect(ConnectionFactory).to receive(:new).and_return(
      @factory
    )
    expect(@factory).to receive(:connection)
    @task = ConnectionTask.new("foo")
    @task.instance_variable_set(:@connection, @connection)
  end

  describe "#log" do
    it "Calls get_log from connection factory" do
      expect(@connection).to receive(:get_log)
      @task.log
    end
  end
end
