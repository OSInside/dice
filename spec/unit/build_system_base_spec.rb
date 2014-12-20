require_relative "spec_helper"

describe BuildSystemBase do
  before(:each) do
    @recipe = Recipe.new("spec/helper/recipe_good")
    expect(@recipe).to receive(:change_working_dir)
    @system = BuildSystemBase.new(@recipe)
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
      expect(File).to receive(:file?).with(/\.dice\/lock/).and_return(false)
      expect(@system.is_locked?).to eq(false)
    end
  end

  describe "#set_lock" do
    it "creates a lock file" do
      lockfile = double(File)
      expect(File).to receive(:new).with(/\.dice\/lock/, "w").and_return(
        lockfile
      )
      expect(lockfile).to receive(:close)
      @system.set_lock
    end
  end

  describe "#release_lock" do
    it "removes a possibly existing lock file" do
      expect(File).to receive(:file?).with(/\.dice\/lock/).and_return(true)
      expect(FileUtils).to receive(:rm).with(/\.dice\/lock/)
      @system.release_lock
    end
  end
end
