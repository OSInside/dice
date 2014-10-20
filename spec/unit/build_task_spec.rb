require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @factory = double(BuildSystemFactory)
    @buildsystem = double(BuildSystem)
    expect(BuildSystemFactory).to receive(:new).and_return(
      @factory
    )
    expect(@factory).to receive(:buildsystem).and_return(
      @buildsystem
    )
    @recipe = double(Recipe)
    @task = BuildTask.new(@recipe)
    @task.instance_variable_set(:@buildsystem, @buildsystem)
  end

  describe "#build_status" do
    it "writes new config.scan and returns with a BuildRequired status" do
      expect(@recipe).to receive(:get_basepath)
      expect(@buildsystem).to receive(:is_locked?).and_return(false)
      expect(Solver).to receive(:writeScan)
      expect(@recipe).to receive(:job_required?).and_return(true)
      expect(@task.build_status).to be_a(Dice::Status::BuildRequired)
    end

    it "returns with a Dice::Status::BuildSystemLocked if locked" do
      expect(@recipe).to receive(:get_basepath)
      expect(@buildsystem).to receive(:is_locked?).and_return(true)
      expect(@buildsystem).to receive(:is_building?).and_return(false)
      expect(@task.build_status).to be_a(Dice::Status::BuildSystemLocked)
    end

    it "returns with a Dice::Status::BuildRunning if build is running" do
      expect(@recipe).to receive(:get_basepath)
      expect(@buildsystem).to receive(:is_locked?).and_return(true)
      expect(@buildsystem).to receive(:is_building?).and_return(true)
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
      expect(@recipe).to receive(:writeRecipeChecksum)
      expect(@task).to receive(:release_lock)
      expect(@task).to receive(:cleanup_screen_job)
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

  describe "#cleanup_screen_job" do
    it "removes the screen job file" do
      expect(@task).to receive(:screen_job_file).and_return("foo")
      expect(File).to receive(:file?).with("foo").and_return(true)
      expect(FileUtils).to receive(:rm).with("foo")
      @task.cleanup_screen_job
    end
  end

  describe "#build_log_file" do
    it "returns build.log file name for recipe" do
      expect(@recipe).to receive(:get_basepath).and_return("foo")
      expect(@task.build_log_file).to eq("foo/.dice/build.log")
    end
  end

  describe "#screen_job_file" do
    it "returns screen job file name" do
      expect(@recipe).to receive(:get_basepath).and_return("foo")
      expect(@task.screen_job_file).to eq("foo/.dice/job")
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
      job = double(Job)
      expect(@factory).to receive(:job).and_return(job)
      expect(job).to receive(:build)
      expect(job).to receive(:bundle)
      expect(job).to receive(:get_result)
      @task.instance_eval{ perform_job }
    end
  end
end
