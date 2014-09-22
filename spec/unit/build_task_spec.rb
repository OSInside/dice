require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @factory = double(BuildSystemFactory)
    @build_system = double(BuildSystem)
    @repos_solver = double(Solve)
    expect(Recipe).to receive(:ok?)
    expect(BuildSystemFactory).to receive(:new).and_return(
      @factory
    )
    expect(@factory).to receive(:buildsystem)
    expect(@factory).to receive(:solver)
    @task = BuildTask.new("foo")
    @task.instance_variable_set(:@build_system, @build_system)
    @task.instance_variable_set(:@repos_solver, @repos_solver)
  end

  describe "#build_status" do
    it "writes new config.scan and returns with a BuildRequired status" do
      expect(@repos_solver).to receive(:writeScan)
      expect(@build_system).to receive(:is_busy?).and_return(false)
      expect(@build_system).to receive(:job_required?).and_return(true)
      expect(@task.build_status).to be_a(Dice::Status::BuildRequired)
    end
  end

  describe "#run" do
    it "starts a box and runs a job" do
      expect(@build_system).to receive(:up)
      expect(@build_system).to receive(:provision)
      expect(@task).to receive(:run_job)
      expect(@task).to receive(:get_result)
      expect(@build_system).to receive(:writeRecipeChecksum)
      expect(@build_system).to receive(:halt)
      @task.run
    end
  end

  describe "#run_job" do
    it "runs a job" do
      job = double(Job)
      expect(@factory).to receive(:job).and_return(job)
      expect(job).to receive(:build)
      @task.instance_eval{ run_job }
    end
  end

  describe "#get_result" do
    it "get result from a job" do
      job = double(Job)
      @task.instance_variable_set(:@job, job)
      expect(job).to receive(:get_result)
      @task.instance_eval{ get_result }
    end
  end

  describe "#cleanup" do
    it "calls halt from the build system" do
      expect(@build_system).to receive(:halt)
      @task.cleanup
    end
  end
end
