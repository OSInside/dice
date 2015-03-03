require_relative "spec_helper"

describe PlainDirRepository do
  before(:each) do
    @meta = OpenStruct.new
    @meta.solv = "bob"
    allow_any_instance_of(PlainDirRepository).to receive(:super)
    allow_any_instance_of(PlainDirRepository).to receive(:solv_meta)
      .and_return(@meta)
    uri = double(Uri)
    allow(uri).to receive(:location)
    @repo = PlainDirRepository.new(uri)
  end

  describe "#solvable" do
    it "creates a solvable from rpm packages" do
      expect(@repo).to receive(:create_tmpdir).and_return("tmp")
      expect(Dir).to receive(:glob).and_return(["some.rpm"])
      expect(@repo).to receive(:curl_file).with(
        :source => "some.rpm", :dest => "tmp/some.rpm"
      )
      expect(@repo).to receive(:create_solv).with(
        :tool => "rpms2solv", :source_dir => "tmp", :dest_dir => "tmp/solv"
      )
      expect(@repo).to receive(:merge_solv)
      expect(@repo).to receive(:cleanup)
      expect(@repo.solvable).to match(@meta.solv)
    end
  end
end
