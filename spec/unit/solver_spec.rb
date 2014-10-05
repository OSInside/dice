require_relative "spec_helper"

describe Solver do
  describe "#self.writeScan" do
    it "raises if kiwi info scan failed" do
      expect(Command).to receive(:run).with(
        "/usr/sbin/kiwi", "--info", "foo",
        "--select", "packages", "--logfile", "terminal", :stdout => :capture
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect { Solver.writeScan("foo") }.to raise_error(
        Dice::Errors::SolvePackagesFailed
      )
    end

    it "stores list of solved packages on success" do
      expect(Command).to receive(:run).and_return(
        "bob <imagescan\n<package=foo"
      )
      recipe_scan = double(File)
      expect(File).to receive(:open).with("foo/.dice/scan", "w").
        and_return(recipe_scan)
      expect(recipe_scan).to receive(:write).with("<package=foo\n")
      expect(recipe_scan).to receive(:close)
      Solver.writeScan("foo")
    end
  end
end
