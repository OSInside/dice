require_relative "spec_helper"

describe Logger do
  describe "#self.info" do
    it "prints a message" do
      expect_any_instance_of(IO).to receive(:puts).with("foo")
      Logger.info("foo")
    end
  end
end
