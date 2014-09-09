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
      expect(@solve).to receive(:cleanup)
      expect(Command).to receive(:run).with(
        "sudo", "/usr/sbin/kiwi", "--info", @recipe_path,
        "--select", "packages", "--logfile", "terminal"
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect { @solve.writeScan }.to raise_error(
        Dice::Errors::SolvePackagesFailed
      )
    end
  end

  describe "#get_info_files" do
    it "glob matches a pattern and returns the result" do
      expect(Dir).to receive(:glob).with("/tmp/kiwi-xmlinfo*").
        and_return(["foo"])
      expect(@solve.instance_eval{ get_info_files }).to eq(["foo"])
    end
  end

  describe "#cleanup" do
    it "removes files from get_info_files and raises on error" do
      expect(@solve).to receive(:get_info_files).and_return(["foo"])
      expect(Command).to receive(:run).with(
        "sudo", "rm", "-f", "foo"
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect{ @solve.instance_eval{ cleanup } }.to raise_error(
        Dice::Errors::SolveCleanUpFailed
      )
    end
  end

  describe "#store_to_receipt" do
    it "stores first file from info result match and raises on error" do
      recipe_scan = @recipe_path + "/config.scan"
      expect(@solve).to receive(:get_info_files).and_return(["foo","xxx"])
      expect(File).to receive(:open).with(recipe_scan, "w")
      expect(Command).to receive(:run).with(
        "sudo", "cat", "foo", :stdout => nil
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect{ @solve.instance_eval{ store_to_receipt } }.to raise_error(
        Dice::Errors::SolveCreateRecipeResultFailed
      )
    end
  end
end
