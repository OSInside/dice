require_relative "spec_helper"

describe Solver do
  before(:each) do
    recipe = double(Recipe)
    allow(recipe).to receive(:basepath).and_return("foo")
    @packages = double(Solver)

    @problems = double
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

    allow(@problems).to receive(:count).and_return(1)
    allow(@problems).to receive(:empty?).and_return(false)
    allow(@problems).to receive(:each).and_return(problem_list)
    allow(solution).to receive(:elements).and_return(solution_options)

    @transaction = double
    dummy_repo = OpenStruct.new
    dummy_repo.name = "foo"
    solvable = double
    allow(@transaction).to receive(:newpackages).and_return([solvable])
    allow(solvable).to receive(:repo).and_return(dummy_repo)
    allow(solvable).to receive(:lookup_num).and_return(0)
    allow(solvable).to receive(:lookup_str).and_return("string")
    allow(solvable).to receive(:lookup_checksum).and_return("checksum")

    @packages = Solver.new(recipe)
  end

  describe "#solve" do
    it "solves packages using libsolv and returns json data" do
      pool = double
      solver = double
      jobs = double
      expect(@packages).to receive(:read_kiwi_config)
      expect(@packages).to receive(:setup_pool).and_return(pool)
      expect(pool).to receive(:Solver).and_return(solver)
      expect(@packages).to receive(:setup_jobs).with(pool).and_return(jobs)
      expect(solver).to receive(:solve).with(jobs)
      expect(solver).to receive(:transaction).and_return(@transaction)
      expect(@packages).to receive(:solver_errors)
      expect(@packages.solve).to eq(
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

    it "raises on solver errors" do
      pool = double
      solver = double
      expect(@packages).to receive(:read_kiwi_config)
      expect(@packages).to receive(:setup_pool).and_return(pool)
      expect(pool).to receive(:Solver).and_return(solver)
      expect(@packages).to receive(:setup_jobs).with(pool)
      expect(solver).to receive(:solve).and_return(@problems)
      expect { @packages.solve }.to raise_error(
        Dice::Errors::SolvJobFailed, /Solver problems: /
      )
    end
  end
end
