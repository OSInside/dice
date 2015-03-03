require_relative "spec_helper"

describe Repository do
  before(:each) do
    @rpmmd_repo = double(RpmMdRepository)
    @suse_repo = double(SuSERepository)
    @plaindir_repo = double(PlainDirRepository)
    @uri = double(Uri)
    allow(@uri).to receive(:name)
    allow(RpmMdRepository).to receive(:new).and_return(@rpmmd_repo)
    allow(SuSERepository).to receive(:new).and_return(@suse_repo)
    allow(PlainDirRepository).to receive(:new).and_return(@plaindir_repo)
  end
 
  describe "#solvable" do
    it "creates a RpmMdRepository" do
      expect(@uri).to receive(:repo_type).and_return(
        Dice::RepoType::RpmMd
      )
      expect(@rpmmd_repo).to receive(:solvable)
      Repository.solvable(@uri)
    end

    it "creates a SuSERepository" do
      expect(@uri).to receive(:repo_type).and_return(
        Dice::RepoType::SUSE
      )
      expect(@suse_repo).to receive(:solvable)
      Repository.solvable(@uri)
    end

    it "creates a PlainDirRepository" do
      expect(@uri).to receive(:repo_type).and_return(
        Dice::RepoType::PlainDir
      )
      expect(@plaindir_repo).to receive(:solvable)
      Repository.solvable(@uri)
    end
  end
end
