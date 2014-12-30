require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @buildsystem = double(BuildSystem)
    @recipe = double(Recipe)
    allow(@buildsystem).to receive(:recipe).and_return(@recipe)
    allow(@recipe).to receive(:basepath).and_return("foo")
    @task = BuildTask.new(@buildsystem)
  end

  describe "#run" do
    it "starts a box and runs a job" do
      status = double(BuildStatus)
      expect(@task).to receive(:status).and_return(status)
      expect(status).to receive(:rebuild?).and_return(true)
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
