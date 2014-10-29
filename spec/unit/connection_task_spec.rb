require_relative "spec_helper"

describe ConnectionTask do
  before(:each) do
    @factory = double(ConnectionFactory)
    expect(ConnectionFactory).to receive(:new).and_return(@factory)
    @task = ConnectionTask.new("foo")
  end

  describe "#log" do
    it "Calls get_log from connection factory" do
      connection = double(Connection)
      expect(@factory).to receive(:get_log)
      @task.log
    end
  end

  describe "#ssh" do
    it "Calls ssh from connection factory" do
      connection = double(Connection)
      expect(@factory).to receive(:ssh)
      @task.ssh
    end
  end
end
