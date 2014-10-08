require_relative "spec_helper"

describe BuildStatus do
  before(:each) do
    @status = Dice::Status::UpToDate.new
  end

  describe "#message" do
    it "prints status message containing derived class name" do
      expect(Logger).to receive(:info).with(
        "Build-System status is: Dice::Status::UpToDate"
      )
      @status.message
    end
  end

  describe "#active_jobs" do
    it "returns list of active screen jobs" do
      expect(File).to receive(:open).with("foo").and_return(["a","b"])
      expect(@status).to receive(:active_job?).with("a")
      expect(@status).to receive(:active_job?).with("b")
      @status.instance_eval{ active_jobs("foo") }
    end
  end

  describe "#active_job?" do
    it "checks if a job is active using screen -X" do
      expect(Command).to receive(:run).with("screen", "-X", "-S", "foo")
      @status.instance_eval{ active_job?("foo") }
    end
  end
end
