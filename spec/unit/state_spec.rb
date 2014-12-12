require_relative "spec_helper"

describe BuildStatus do
  before(:each) do
    @status = Dice::Status::UpToDate.new
    @recipe = double(Recipe)
  end

  describe "#message" do
    it "prints status message containing derived class name" do
      jobs = ["last-run", "current-run"]
      expect(Dice::logger).to receive(:info).with(
        "BuildStatus: Dice::Status::UpToDate"
      )
      expect(@status).to receive(:job_info).with(@recipe)
      expect(@status).to receive(:result_info).with(@recipe)
      @status.message @recipe
    end
  end
end
