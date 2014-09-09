require_relative "spec_helper"

describe Solve do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    system = BuildSystem.new("spec/helper/recipe_good")
    @solve = Solve.new(system)
    @recipe_path = system.get_basepath
  end

  describe "#writeScan" do
    it "raises if kiwi info scan failed" do
      expect(Command).to receive(:run).with(
        "sudo", "/usr/sbin/kiwi", "--info", @recipe_path,
        "--select", "packages", "--logfile", "terminal", :stdout => :capture
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect { @solve.writeScan }.to raise_error(
        Dice::Errors::SolvePackagesFailed
      )
    end

    it "calls store_to_receipt on success" do
      expect(Command).to receive(:run)
      expect(@solve).to receive(:store_to_receipt)
      @solve.writeScan
    end
  end

  describe "#store_to_receipt" do
    it "stores config.scan in recipe directory" do
      recipe_scan = @recipe_path + "/config.scan"
      expect(File).to receive(:open).with(recipe_scan, "w").
        and_return(File.new(recipe_scan, "w"))
      expect_any_instance_of(File).to receive(:write).with("<package=foo\n")
      @solve.instance_eval{ store_to_receipt("bob <imagescan\n<package=foo") }
    end
  end
end
