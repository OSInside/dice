require_relative "spec_helper"

describe Cleaner do
  before(:each) do
    @buildsystem = double(BuildSystem)
    @cleaner = Cleaner.new(@buildsystem)
  end

  describe "#clean_stale_lock" do
    it "remove semaphore lock if buildsystem is not building" do
      expect(@buildsystem).to receive(:is_building?).and_return(false)
      expect(@buildsystem).to receive(:set_lock).and_return(42)
      expect(@buildsystem).to receive(:release_lock)
      @cleaner.clean_stale_lock
    end

    it "raises if buildsystem is building a job" do
      expect(@buildsystem).to receive(:is_building?).and_return(true)
      expect { @cleaner.clean_stale_lock }.to raise_error(
        Dice::Errors::ActiveSemaphoreLock
      )
    end
  end
end
