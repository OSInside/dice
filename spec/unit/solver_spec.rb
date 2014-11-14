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
    it "returns array of hashes with solver result information" do
      transaction = double
      dummy_repo = OpenStruct.new
      dummy_repo.name = "foo"
      solvable = double
      expect(transaction).to receive(:newpackages).and_return([solvable])
      expect(solvable).to receive(:repo).and_return(dummy_repo)
      allow(solvable).to receive(:lookup_num).and_return(0)
      allow(solvable).to receive(:lookup_str).and_return("string")
      allow(solvable).to receive(:lookup_checksum).and_return("checksum")
      expect(@solver.solve_result(transaction)).to eq(
        [{
           "string" =>
           {
             :url => "foo",
             :installsize => 0,
             :arch =>"string",
             :evr => "string",
             :checksum =>"checksum"
           }
        }]
      )
    end
  end

  describe "#solve_errors" do
    it "returns a json hash with solver problem information" do
      problems = double

      solution = OpenStruct.new
      solution.id = 1

      option = OpenStruct.new
      option.str = "some-solution"
      solution_options = [ option ]

      problem = OpenStruct.new
      problem.id = 1
      problem.findproblemrule = OpenStruct.new
      problem.findproblemrule.info = OpenStruct.new
      problem.findproblemrule.info.problemstr = "some-problem"
      problem.solutions = [ solution ]

      problem_list = [ problem ]

      expect(problems).to receive(:count).and_return(1)

      expect(problems).to receive(:empty?).and_return(false)

      expect(problems).to receive(:each).and_return(problem_list)

      expect(solution).to receive(:elements).and_return(solution_options)

      expect(JSON).to receive(:pretty_generate).and_return("problem")

      expect { @solver.solve_errors(problems) }.to raise_error(
        Dice::Errors::SolvJobFailed, "Solver problems: problem"
      )
    end
  end
end
