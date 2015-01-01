require_relative "spec_helper"

describe BuildSystemBase do
  before(:each) do
    @description = "some-description-dir"
    @lockfile = "some-lock-file"
    recipe = Recipe.new(@description)
    allow(recipe).to receive(:basepath).and_return(@description)
    allow(recipe).to receive(:change_working_dir)
    allow_any_instance_of(BuildSystemBase).to receive(:get_lockfile).and_return(
      @lockfile
    )
    @system = BuildSystemBase.new(recipe)
  end

  describe "#is_building?" do
    it "checks if a process currently access the build log" do
      expect(Command).to receive(:run).with(
        "fuser", /build\.log/, {:stdout => :capture}
      ).and_raise(Cheetah::ExecutionFailed.new(nil, nil, nil, nil))
      expect(@system.is_building?).to eq(false)
    end
  end

  describe "#is_locked?" do
    it "checks semaphore value and returns lock boolean state" do
      semaphore = double(Semaphore)
      expect(@system).to receive(:semaphore).and_return(semaphore)
      expect(@system).to receive(:semaphore_id).and_return(42)
      expect(semaphore).to receive(:getval).and_return(0)
      expect(@system.is_locked?).to eq(false)
    end
  end

  describe "#set_lock" do
    it "set semaphore value to lock state = 1" do
      semaphore = double(Semaphore)
      expect(@system).to receive(:semaphore).and_return(semaphore)
      expect(@system).to receive(:semaphore_id).and_return(42)
      expect(semaphore).to receive(:setval).with(42, 1)
      @system.set_lock
    end
  end

  describe "#release_lock" do
    it "delete semaphore" do
      semaphore = double(Semaphore)
      expect(@system).to receive(:semaphore).and_return(semaphore)
      expect(@system).to receive(:semaphore_id).and_return(42)
      expect(semaphore).to receive(:remove).with(42)
      @system.instance_variable_set(:@set_lock_called, true)
      @system.release_lock
    end
  end

  describe "#prepare_job" do
    it "creates a new job instance" do
      expect(Job).to receive(:new).with(@system)
      @system.prepare_job
    end
  end

  describe "#import_build_options" do
    it "imports build options from recipe meta data" do
      build_options = double(File)
      expect(File).to receive(:open).with(
        @description + "/" + Dice::META + "/" + Dice::BUILD_OPTS_FILE, "rb"
      ).and_return(build_options)
      expect(Marshal).to receive(:load).with(build_options)
      expect(build_options).to receive(:close)
      @system.import_build_options
    end
  end
end
