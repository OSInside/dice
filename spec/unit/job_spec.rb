require_relative "spec_helper"

describe Job do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    expect_any_instance_of(BuildSystem).to receive(:get_ip)
    @job = Job.new(BuildSystem.new("spec/helper/recipe_good"))
  end

  describe "#initialize" do
    it "raises if job gets no BuildSystem" do
      expect { Job.new(File) }.to raise_error
    end
  end

  describe "#build" do
    it "raises if build failed" do
      expect(@job).to receive(:prepare_build)
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@job).to receive(:get_buildlog)
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.build }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#get_result" do
    it "raises if result retrieval failed" do
      expect(File).to receive(:open)
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.get_result }.to raise_error(
        Dice::Errors::ResultRetrievalFailed
      )
    end
  end

  describe "#prepare_build" do
  end

  describe "#get_buildlog" do
  end
end
