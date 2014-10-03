require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @factory = double(BuildSystemFactory)
    @buildsystem = double(BuildSystem)
    @job = double(Job)
    expect(Recipe).to receive(:ok?)
    expect(BuildSystemFactory).to receive(:new).and_return(
      @factory
    )
    expect(@factory).to receive(:buildsystem).and_return(
      @buildsystem
    )
    expect(@factory).to receive(:job).and_return(
      @job
    )
    @task = BuildTask.new("foo")
    @task.instance_variable_set(:@buildsystem, @buildsystem)
    @task.instance_variable_set(:@job, @job)
  end

  describe "#build_status" do
    it "writes new config.scan and returns with a BuildRequired status" do
      expect(@buildsystem).to receive(:is_busy?).and_return(false)
      expect(@task).to receive(:set_lock)
      expect(Solver).to receive(:writeScan)
      expect(@buildsystem).to receive(:job_required?).and_return(true)
      expect(@task).to receive(:release_lock)
      expect(@task.build_status).to be_a(Dice::Status::BuildRequired)
    end

    it "returns with a Dice::Status::BuildRunning if busy" do
      expect(@buildsystem).to receive(:is_busy?).and_return(true)
      expect(@task.build_status).to be_a(Dice::Status::BuildRunning)
    end
  end

  describe "#run" do
    it "starts a box and runs a job" do
      expect(@task).to receive(:build_status).and_return(
        Dice::Status::BuildRequired.new
      )
      expect(@task).to receive(:set_lock)
      expect(@buildsystem).to receive(:up)
      expect(@buildsystem).to receive(:provision)
      expect(@task).to receive(:perform_job)
      expect(@buildsystem).to receive(:writeRecipeChecksum)
      expect(@task).to receive(:release_lock)
      expect(@buildsystem).to receive(:halt)
      @task.run
    end
  end

  describe "#log" do
    it "calls get_log on a BuildSystem" do
      expect(@buildsystem).to receive(:get_log)
      @task.log
    end
  end

  describe "#cleanup" do
    it "calls halt from the build system" do
      expect(@task).to receive(:release_lock)
      expect(@buildsystem).to receive(:halt)
      @task.cleanup
    end
  end

  describe "#set_lock" do
    it "calls set_lock from the buildsystem" do
      expect(@buildsystem).to receive(:set_lock)
      @task.set_lock
    end
  end

  describe "#release_lock" do
    it "calls release_lock from the buildsystem" do
      expect(@buildsystem).to receive(:release_lock)
      @task.release_lock
    end
  end

  describe "#perform_job" do
    it "runs a job and get the result" do
      expect(@job).to receive(:build)
      expect(@job).to receive(:bundle)
      expect(@job).to receive(:get_result)
      @task.instance_eval{ perform_job }
    end
  end
end
