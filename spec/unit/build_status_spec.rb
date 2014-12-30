require_relative "spec_helper"

describe BuildStatus do
  before(:each) do
    buildsystem = double(BuildSystem)
    allow(buildsystem).to receive(:recipe)
    expect_any_instance_of(BuildStatus).to receive(:init_status)
    @status = BuildStatus.new(
      buildsystem
    )
  end

  describe "#message" do
    it "construct status message for status, job and build result info" do
      expect(@status).to receive(:status_info)
      expect(@status).to receive(:active_job_info)
      expect(@status).to receive(:build_result_info)
      @status.message
    end
  end

  describe "#rebuild?" do
    it "checks if a description needs to be rebuild" do
      expect(@status).to receive(:locked).and_return(false)
      expect(@status).to receive(:uptodate).and_return(true)
      expect(@status.rebuild?).to eq(false)
    end
  end
end
