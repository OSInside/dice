require_relative "spec_helper"

describe KiwiUri do
  describe "#self.translate" do
    it "translates dist obs url to http mime type pointing to opensuse.org" do
      expect(KiwiUri.translate(
        :name => "obs://openSUSE:13.1:Update/standard", :repo_type => "yast2"
      ).name).to eq(
        "http://download.opensuse.org/repositories/openSUSE:/13.1:/Update/standard"
      )
    end

    it "translates dist obs url to http mime type pointing to opensuse.org" do
      expect(KiwiUri.translate(
        :name => "obs://13.1/repos", :repo_type => "yast2"
      ).name).to eq(
        "http://download.opensuse.org/distribution/13.1/repos/"
      )
    end

    it "translates path to dir mime type" do
      expect(File).to receive(:exists?).and_return(true)
      expect(KiwiUri.translate(
        :name => "/some/path", :repo_type => "rpm-md"
      ).name).to eq(
        "dir:///some/path/"
      )
    end

    it "translates http url by leaving it as it is" do
      expect(KiwiUri.translate(
        :name => "http://xxx", :repo_type => "rpm-md"
      ).name).to eq(
        "http://xxx"
      )
    end
  end
end
