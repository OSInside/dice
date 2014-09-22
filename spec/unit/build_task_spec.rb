require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @factory = double(BuildSystemFactory)
    expect(Recipe).to receive(:ok?)
    expect(BuildSystemFactory).to receive(:new).and_return(
      @factory
    )
    @task = BuildTask.new("foo")
  end

  describe "#build_status" do
    it "writes new config.scan and returns with a BuildRequired status" do
      build_system = double(BuildSystem)
      expect(Solver).to receive(:writeScan)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:is_busy?).and_return(false)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:job_required?).and_return(true)
      expect(@task.build_status).to be_a(Dice::Status::BuildRequired)
    end
  end

  describe "#run" do
    it "starts a box and runs a job" do
      build_system = double(BuildSystem)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:up)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:provision)
      expect(@task).to receive(:perform_job)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:writeRecipeChecksum)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:halt)
      @task.run
    end
  end

  describe "#log" do
    it "calls get_log on a BuildSystem" do
      build_system = double(BuildSystem)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:get_log)
      @task.log
    end
  end

  describe "#cleanup" do
    it "calls halt from the build system" do
      build_system = double(BuildSystem)
      expect(@factory).to receive(:buildsystem).and_return(build_system)
      expect(build_system).to receive(:halt)
      @task.cleanup
    end
  end

  describe "#perform_job" do
    it "runs a job and get the result" do
      job = double(Job)
      expect(@factory).to receive(:job).and_return(job)
      expect(job).to receive(:build)
      expect(job).to receive(:get_result)
      @task.instance_eval{ perform_job }
    end
  end
end
