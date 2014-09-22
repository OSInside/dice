require_relative "spec_helper"

describe ConnectionTask do
  before(:each) do
    @factory = double(ConnectionFactory)
    expect(Recipe).to receive(:ok?)
    expect(ConnectionFactory).to receive(:new).and_return(@factory)
    @task = ConnectionTask.new("foo")
  end

  describe "#log" do
    it "Calls get_log from connection factory" do
      connection = double(Connection)
      expect(@factory).to receive(:connection).and_return(connection)
      expect(connection).to receive(:get_log)
      @task.log
    end
  end
end
