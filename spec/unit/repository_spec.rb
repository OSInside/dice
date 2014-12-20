require_relative "spec_helper"

describe Repository do
  before(:each) do
    @rpmmd_repo = double(RpmMdRepository)
    @suse_repo = double(SuSERepository)
    allow(RpmMdRepository).to receive(:new).and_return(@rpmmd_repo)
    allow(SuSERepository).to receive(:new).and_return(@suse_repo)
  end
 
  describe "#solvable" do
    it "creates a RpmMdRepository" do
      uri = "/repodata/repomd.xml.key"
      expect(Repository).to receive(:repotype).with(uri).and_return(
        Dice::RepoType::RpmMd
      )
      expect(@rpmmd_repo).to receive(:solvable)
      Repository.solvable(uri)
    end

    it "creates a SuSERepository" do
      uri = "/suse/setup/descr/directory.yast"
      expect(Repository).to receive(:repotype).with(uri).and_return(
        Dice::RepoType::SUSE
      )
      expect(@suse_repo).to receive(:solvable)
      Repository.solvable(uri)
    end
  end
end
