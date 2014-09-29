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
end
