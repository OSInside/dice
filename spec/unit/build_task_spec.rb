require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @buildsystem = double(BuildSystem)
    @recipe = double(Recipe)
    allow(@buildsystem).to receive(:recipe).and_return(@recipe)
    allow(@recipe).to receive(:basepath).and_return("foo")
    @task = BuildTask.new(@buildsystem)
    @task.instance_variable_set(:@buildsystem, @buildsystem)
  end

  describe "#build_status" do
    it "returns with a BuildRequired status if not up to date" do
      expect(@buildsystem).to receive(:is_locked?).and_return(false)
      expect(@recipe).to receive(:uptodate?).and_return(false)
      expect(@task.build_status).to be_a(Dice::Status::BuildRequired)
    end

    it "returns with a Dice::Status::BuildSystemLocked if locked" do
      expect(@buildsystem).to receive(:is_locked?).and_return(true)
      expect(@buildsystem).to receive(:is_building?).and_return(false)
      expect(@task.build_status).to be_a(Dice::Status::BuildSystemLocked)
    end

    it "returns with a Dice::Status::BuildRunning if build is running" do
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
      expect(@buildsystem).to receive(:set_lock)
      expect(@buildsystem).to receive(:up)
      expect(@buildsystem).to receive(:provision)
      expect(@task).to receive(:perform_job)
      expect(@recipe).to receive(:update)
      expect(@task).to receive(:cleanup)
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
      job_file="foo/.dice/job"
      expect(@buildsystem).to receive(:release_lock)
      expect(File).to receive(:file?).with(job_file).and_return(true)
      expect(FileUtils).to receive(:rm).with(job_file)
      expect(@buildsystem).to receive(:halt)
      @task.cleanup
    end
  end
end
