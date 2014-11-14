require_relative "spec_helper"

describe SuSERepository do
  before(:each) do
    @meta = OpenStruct.new
    @meta.solv = "bob"
    allow_any_instance_of(SuSERepository).to receive(:super)
    allow_any_instance_of(SuSERepository).to receive(:solv_meta)
      .and_return(@meta)
    @repo = SuSERepository.new("foo")
  end

  describe "#solvable" do
    it "returns with initialized solvable if it is up to data" do
      expect(@repo).to receive(:uptodate?).and_return(true)
      expect(@repo.solvable).to match(@meta.solv)
    end

    it "create a solvable from repodata" do
      expect(@repo).to receive(:uptodate?).and_return(false)
      expect(@repo).to receive(:create_tmpdir).and_return("tmp")
      expect(@repo).to receive(:get_pattern_files).and_return(["a", "b"])
      expect(@repo).to receive(:curl_file).with("a", "tmp/a")
      expect(@repo).to receive(:curl_file).with("b", "tmp/b")
      expect(@repo).to receive(:create_solv).with(
        "susetags2solv", "tmp", "tmp/solv"
      )
      primary_files = OpenStruct.new
      primary_files.list = ["a", "b"]
      primary_files.tool = "yadayada"
      expect(@repo).to receive(:get_primary_files).and_return(primary_files)
      expect(@repo).to receive(:curl_file).with("a", "tmp/primary/a")
      expect(@repo).to receive(:curl_file).with("b", "tmp/primary/b")
      expect(@repo).to receive(:create_solv).with(
        primary_files.tool, "tmp/primary", "tmp/solv"
      )
      expect(@repo).to receive(:merge_solv).with("tmp/solv")
      expect(@repo).to receive(:cleanup)
      expect(@repo.solvable).to match(@meta.solv)
    end
  end
end
