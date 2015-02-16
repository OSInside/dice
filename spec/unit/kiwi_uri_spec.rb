require_relative "spec_helper"

describe KiwiUri do
  describe "#self.translate" do
    it "translates dist obs url to http mime type pointing to opensuse.org" do
      expect(KiwiUri.translate("obs://13.1/repos").name).to eq(
        "http://download.opensuse.org/distribution/13.1/repos/"
      )
    end

    it "translates path to dir mime type" do
      expect(KiwiUri.translate("/some/path").name).to eq(
        "dir:///some/path/"
      )
    end

    it "translates http url by leaving it as it is" do
      expect(KiwiUri.translate("http://xxx").name).to eq(
        "http://xxx"
      )
    end
  end
end
