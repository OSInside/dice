require_relative "spec_helper"

describe BuildTask do
  before(:each) do
    @buildsystem = double(BuildSystem)
    expect(BuildSystem).to receive(:new).and_return(
      @buildsystem
    )
    @recipe = double(Recipe)
    @task = BuildTask.new(@recipe)
    @task.instance_variable_set(:@buildsystem, @buildsystem)
  end

  describe "#build_status" do
    it "writes new config.scan and returns with a BuildRequired status" do
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
      expect(@task).to receive(:set_lock)
      expect(@buildsystem).to receive(:up)
      expect(@buildsystem).to receive(:provision)
      expect(@task).to receive(:perform_job)
      expect(@recipe).to receive(:update)
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
end
