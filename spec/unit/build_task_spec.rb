require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @build_system = double(BuildSystem)
    @repos_solver = double(Solve)
    expect(BuildSystem).to receive(:new).and_return(@build_system)
    expect(Solve).to receive(:new).and_return(@repos_solver)
    @task = BuildTask.new("foo")
  end

  describe "#build_status" do
    it "writes new config.scan and returns with a BuildRequired status" do
      expect(@repos_solver).to receive(:writeScan)
      expect(@build_system).to receive(:is_locked?).and_return(false)
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
      expect(Job).to receive(:new).with(@build_system).and_return(job)
      expect(job).to receive(:build)
      @task.instance_eval{ run_job }
    end
  end

  describe "#get_result" do
    it "" do
      job = double(Job)
      @task.instance_variable_set(:@job, job)
      expect(job).to receive(:get_result)
      @task.instance_eval{ get_result }
    end
  end
end
