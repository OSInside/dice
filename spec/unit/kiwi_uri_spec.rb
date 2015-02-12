require_relative "spec_helper"

describe KiwiUri do
  describe "#self.translate" do
    it "translates dist obs url to download.opensuse.org" do
      expect(KiwiUri.translate("obs://13.1/repos")).to eq(
        "http://download.opensuse.org/distribution/13.1/repos/"
      )
    end

    it "translates dir url to full path" do
      expect(KiwiUri.translate("dir:///some/path")).to eq(
        "/some/path"
      )
    end

    it "translates path by leaving it as it is" do
      expect(KiwiUri.translate("/some/path")).to eq(
        "/some/path"
      )
    end

    it "translates http url by leaving it as it is" do
      expect(KiwiUri.translate("http://xxx")).to eq(
        "http://xxx"
      )
    end

    it "raises on unknown uri type" do
      expect { KiwiUri.translate("bob") }.to raise_error(
        Dice::Errors::UriTypeUnknown
      )
    end
  end
end
