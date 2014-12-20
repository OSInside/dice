require_relative "spec_helper"

describe ConnectionTask do
  before(:each) do
    @connection = double(Connection)
    expect(Connection).to receive(:new).and_return(@connection)
    @task = ConnectionTask.new("foo")
  end

  describe "#log" do
    it "Calls get_log from a connection" do
      expect(@connection).to receive(:get_log)
      @task.log
    end
  end

  describe "#ssh" do
    it "Calls ssh from a connection" do
      expect(@connection).to receive(:ssh)
      @task.ssh
    end
  end
end
