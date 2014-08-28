require_relative "spec_helper"

describe Command do
  describe "#self.run" do
    it "calls Cheetah.run with all given arguments" do
      args = "foo -x -y"
      expect(Cheetah).to receive(:run).with(args)
      Command.run(args)
    end
  end
end
