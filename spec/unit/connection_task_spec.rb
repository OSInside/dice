require_relative "spec_helper"

describe ConnectionTask do
  before(:each) do
    @connection = double(Connection)
    expect(Recipe).to receive(:ok?)
    expect(ConnectionFactory).to receive(:from_recipe).and_return(
      @connection
    )
    @task = ConnectionTask.new("foo")
  end

  describe "#log" do
    it "Calls get_log from connection factory" do
      expect(@connection).to receive(:get_log)
      @task.log
    end
  end
end
