require_relative "spec_helper"

describe BuildSystemBase do
  before(:each) do
    description = "some-description-dir"
    @lockfile = "some-lock-file"
    recipe = Recipe.new(description)
    allow(recipe).to receive(:basepath).and_return(description)
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
    it "checks if a lock file exists" do
      expect(File).to receive(:file?).with(@lockfile).and_return(false)
      expect(@system.is_locked?).to eq(false)
    end
  end

  describe "#set_lock" do
    it "creates a lock file" do
      lockfile = double(File)
      expect(File).to receive(:new).with(@lockfile, "w").and_return(
        lockfile
      )
      expect(lockfile).to receive(:close)
      @system.set_lock
    end
  end

  describe "#release_lock" do
    it "removes a possibly existing lock file" do
      expect(File).to receive(:file?).with(@lockfile).and_return(true)
      expect(FileUtils).to receive(:rm).with(@lockfile)
      @system.release_lock
    end
  end

  describe "#prepare_job" do
    it "creates a new job instance" do
      expect(Job).to receive(:new).with(@system)
      @system.prepare_job
    end
  end
end
