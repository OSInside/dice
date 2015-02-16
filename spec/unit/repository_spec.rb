require_relative "spec_helper"

describe Repository do
  before(:each) do
    @rpmmd_repo = double(RpmMdRepository)
    @suse_repo = double(SuSERepository)
    @uri = double(Uri)
    allow(@uri).to receive(:name)
    allow(RpmMdRepository).to receive(:new).and_return(@rpmmd_repo)
    allow(SuSERepository).to receive(:new).and_return(@suse_repo)
  end
 
  describe "#solvable" do
    it "creates a RpmMdRepository" do
      expect(Repository).to receive(:repotype).and_return(
        Dice::RepoType::RpmMd
      )
      expect(@rpmmd_repo).to receive(:solvable)
      Repository.solvable(@uri)
    end

    it "creates a SuSERepository" do
      expect(Repository).to receive(:repotype).and_return(
        Dice::RepoType::SUSE
      )
      expect(@suse_repo).to receive(:solvable)
      Repository.solvable(@uri)
    end
  end
end
