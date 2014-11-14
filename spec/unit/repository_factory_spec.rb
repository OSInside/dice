require_relative "spec_helper"

describe RepositoryFactory do
  before(:each) do
    @rpmmd_repo = double(RpmMdRepository)
    @suse_repo = double(SuSERepository)
    allow(RpmMdRepository).to receive(:new).and_return(@rpmmd_repo)
    allow(SuSERepository).to receive(:new).and_return(@suse_repo)
  end
 
  describe "#new" do
    it "creates a RpmMdRepository" do
      expect(File).to receive(:open).with("/repodata/repomd.xml.key", "rb")
      expect(RepositoryFactory.new("")).to eq(@rpmmd_repo)
    end

    it "creates a SuSERepository" do
      expect(File).to receive(:open).and_raise
      expect(RepositoryFactory.new("")).to eq(@suse_repo)
    end
  end
end
