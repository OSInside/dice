require_relative "spec_helper"

describe RpmMdRepository do
  before(:each) do
    @meta = OpenStruct.new
    @meta.solv = "bob"
    @rxml = double(REXML::Document)
    allow_any_instance_of(RpmMdRepository).to receive(:super)
    allow_any_instance_of(RpmMdRepository).to receive(:solv_meta)
      .and_return(@meta)
    allow_any_instance_of(RpmMdRepository).to receive(:get_repoxml)
      .and_return(@rxml)
    uri = double(Uri)
    @repo = RpmMdRepository.new(uri)
  end

  describe "#solvable" do
    it "returns with initialized solvable if it is up to data" do
      expect(@repo).to receive(:timestamp)
      expect(@repo).to receive(:uptodate?).and_return(true)
      expect(@repo.solvable).to match(@meta.solv)
    end

    it "create a solvable from repodata" do
      expect(@repo).to receive(:timestamp).and_return("today")
      expect(@repo).to receive(:uptodate?).and_return(false)
      expect(@repo).to receive(:create_tmpdir).and_return("tmp")
      expect(@repo).to receive(:get_repomd_files).and_return(["a", "b"])
      expect(@repo).to receive(:curl_file).with(
        :source => "a", :dest => "tmp/a"
      )
      expect(@repo).to receive(:curl_file).with(
        :source => "b", :dest => "tmp/b"
      )
      expect(@repo).to receive(:create_solv).with(
        :tool => "rpmmd2solv", :source_dir => "tmp", :dest_dir => "tmp/solv"
      )
      expect(@repo).to receive(:get_pattern_files).and_return(["a", "b"])
      expect(@repo).to receive(:curl_file).with(
        :source => "a", :dest => "tmp/patterns/a"
      )
      expect(@repo).to receive(:curl_file).with(
        :source => "b", :dest => "tmp/patterns/b"
      )
      expect(@repo).to receive(:create_solv).with(
        :tool => "susetags2solv", :source_dir => "tmp/patterns",
        :dest_dir => "tmp/solv"
      )
      expect(Command).to receive(:exists?).with(
        "comps2solv"
      ).and_return(true)
      expect(@repo).to receive(:get_group_files).and_return(["a", "b"])
      expect(@repo).to receive(:create_solv).with(
        :tool => "comps2solv", :source_dir => "tmp/groups",
        :dest_dir => "tmp/solv"
      )
      expect(@repo).to receive(:merge_solv).with("tmp/solv", "today")
      expect(@repo).to receive(:cleanup)
      expect(@repo.solvable).to match(@meta.solv)
    end
  end
end
