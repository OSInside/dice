require_relative "spec_helper"

describe Command do
  describe "#self.run" do
    it "calls Cheetah.run with all given arguments" do
      args = "foo -x -y"
      expect(Cheetah).to receive(:run).with(args)
      Command.run(args)
    end
  end

  describe "#self.exists" do
    it "checks via which if command exists and returns true" do
      expect(Command.exists?("bash")).to eq(true)
    end

    it "checks via which if command exists and returns false" do
      expect(Command.exists?("foo")).to eq(false)
    end
  end
end
