require_relative "spec_helper"

describe Solve do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    system = VagrantBuildSystem.new("spec/helper/recipe_good")
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

    it "calls store_to_recipe on success" do
      expect(Command).to receive(:run)
      expect(@solve).to receive(:store_to_recipe)
      @solve.writeScan
    end
  end

  describe "#store_to_recipe" do
    it "stores config.scan in recipe directory" do
      recipe_solv = @recipe_path + "/config.scan"
      recipe_scan = double(File)
      expect(File).to receive(:open).with(recipe_solv, "w").
        and_return(recipe_scan)
      expect(recipe_scan).to receive(:write).with("<package=foo\n")
      expect(recipe_scan).to receive(:close)
      @solve.instance_eval{ store_to_recipe("bob <imagescan\n<package=foo") }
    end
  end
end
