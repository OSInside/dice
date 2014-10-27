require_relative "spec_helper"

describe Solver do
  before(:each) do
    recipe = double(Recipe)
    allow(recipe).to receive(:get_basepath).and_return("foo")
    @solver = double(Solver)
    @kiwi_config = double(KiwiConfig)
    allow(KiwiConfig).to receive(:new).and_return(@kiwi_config)
    @solver = Solver.new(recipe)
  end

  describe "#writeScan" do
    it "stores json formatted list of solved packages and their attrs" do
      solver_result = OpenStruct.new
      solver_result.problems = []
      solver_result.transaction = []
      expect(@solver).to receive(:solve).and_return(solver_result)
      expect(@solver).to receive(:solve_errors)
      expect(@solver).to receive(:solve_result)
      recipe_scan = double(File)
      expect(File).to receive(:open).with("foo/.dice/scan", "w").
        and_return(recipe_scan)
      expect(JSON).to receive(:pretty_generate).and_return("foo")
      expect(recipe_scan).to receive(:write).with("foo")
      expect(recipe_scan).to receive(:close)
      @solver.writeScan
    end
  end

  describe "#solve_result" do
    # TODO
  end

  describe "#solve_errors" do
    # TODO
  end
end
