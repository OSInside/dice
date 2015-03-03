require_relative "spec_helper"

describe Uri do
  describe "#initialize" do
    it "raises on invalid uri type" do
      expect {
        Uri.new(:name => "foo://lala", :repo_type => "rpm-md")
      }.to raise_error(
        Dice::Errors::UriTypeUnknown
      )
    end

    it "raises on malformed uri" do
      expect {
        Uri.new(:name => "foofoo", :repo_type => "rpm-md")
      }.to raise_error(
        Dice::Errors::UriStyleMatchFailed
      )
    end
  end

  describe "#is_remote?" do
    it "returns true for an http uri" do
      uri = Uri.new(:name => "http://foo", :repo_type => "rpm-md")
      expect(uri.is_remote?).to eq(true)
    end
  end

  describe "#is_iso?" do
    it "returns true for an iso uri" do
      uri = Uri.new(:name => "iso://foo", :repo_type => "rpm-md")
      expect(uri.is_iso?).to eq(true)
    end
  end

  describe "map_loop" do
    it "loop mounts the uri location" do
      uri = Uri.new(:name => "iso://foo", :repo_type => "rpm-md")
      expect(uri).to receive(:mount_loop)
      uri.map_loop
    end
  end

  describe "unmap_loop" do
    it "umounts the currently stored mount location" do
      uri = Uri.new(:name => "iso://foo", :repo_type => "rpm-md")
      expect(uri).to receive(:mount_loop).and_return("foo")
      expect(uri).to receive(:umount_loop).with("foo")
      uri.map_loop
      uri.unmap_loop
    end
  end
end
