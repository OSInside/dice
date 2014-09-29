require_relative "spec_helper"

describe BuildStatus do
  before(:each) do
    @status = Dice::Status::UpToDate.new
  end

  describe "#message" do
    it "prints status message containing derived class name" do
      expect(@status.message).to eq(
        "[#{$$}]: Build-System status is: Dice::Status::UpToDate"
      )
    end
  end
end
