require_relative "spec_helper"

describe RepositoryBase do
  before(:each) do
    allow(Kernel).to receive(:rand).and_return(5)
    @meta = double(OpenStruct)
    allow(@meta).to receive(:solv).and_return("foo")
    allow(@meta).to receive(:time).and_return("today")
    allow(@meta).to receive(:info).and_return("info")
    @kiwi_solv_pool = "/var/tmp/kiwi/satsolver"
    @uri = "http://foo"
    @source = "bar"
    @repo = RepositoryBase.new(@uri)
  end

  describe "#load_file" do
    it "reads in a file supporting ruby open-uri and return its contents" do
      file = double(File)
      expect(@repo).to receive(:open).with(
        @uri + "/" + @source, "rb"
      ).and_return(file)
      expect(file).to receive(:read).and_return("data")
      expect(@repo.load_file(@source)).to eq("data")
    end

    it "raises if file could not be opened" do
      expect(@repo).to receive(:open).with(
        @uri + "/" + @source, "rb"
      ).and_raise(
        Dice::Errors::UriLoadFileFailed.new(nil)
      )
      expect{ @repo.load_file(@source) }.to raise_error(
        Dice::Errors::UriLoadFileFailed
      )
    end
  end

  describe "#curl_file" do
    it "calls curl to download a file from the network and store it as file" do
      dest = "/some/path/somewhere"
      outfile = double(File)
      expect(FileUtils).to receive(:mkdir_p).with("/some/path")
      expect(File).to receive(:open).with(dest, "wb").and_return(outfile)
      expect(Cheetah).to receive(:run).with(
        "curl", "-L", @uri + "/" + @source, :stdout => outfile
      )
      expect(outfile).to receive(:close)
      @repo.curl_file(:source => @source, :dest => dest)
    end

    it "raises if curl can't find the file" do
      expect(FileUtils).to receive(:mkdir_p)
      expect(File).to receive(:open)
      expect(Cheetah).to receive(:run).and_raise(
        Dice::Errors::CurlFileFailed.new(nil)
      )
      expect{ @repo.curl_file(:source => @source, :dest => "") }.to raise_error(
        Dice::Errors::CurlFileFailed
      )
    end
  end

  describe "#create_solv" do
    it "creates a solvable with a randomized name" do
      dest_dir = "/some/dest-path"
      source_dir = "/some/source-path"
      tool = "mytool"
      solvable = double(File)
      expect(FileUtils).to receive(:mkdir_p).with(dest_dir)
      expect(File).to receive(:open).with(
        dest_dir + "/solvable-FFFFFFFF", "wb"
      ).and_return(solvable)
      expect(Cheetah).to receive(:run).with(
        "bash", "-c", "gzip -cd --force #{source_dir}/* | #{tool}",
        :stdout => solvable
      )
      expect(solvable).to receive(:close)
      expect(@repo.create_solv(
        :tool => tool, :source_dir => source_dir, :dest_dir => dest_dir
      )).to eq(
        "solvable-FFFFFFFF"
      )
    end

    it "raises if solver tool failed" do
      expect(FileUtils).to receive(:mkdir_p)
      expect(File).to receive(:open)
      expect(Cheetah).to receive(:run).and_raise(
        Dice::Errors::SolvToolFailed.new(nil)
      )
      expect{ @repo.create_solv(
        :tool => "", :source_dir => "", :dest_dir => ""
      ) }.to raise_error(
        Dice::Errors::SolvToolFailed
      )
    end
  end

  describe "#merge_solv" do
    it "merges solvables from a directory into a master solvable" do
      source_dir = "/some/source-path"
      solvable = double(File)
      expect(@repo).to receive(:solv_meta).and_return(@meta)
      expect(File).to receive(:exists?).with(@kiwi_solv_pool).and_return(false)
      expect(FileUtils).to receive(:mkdir_p).with(@kiwi_solv_pool)
      expect(File).to receive(:open).with(
        @kiwi_solv_pool + "/" + @meta.solv, "wb"
      ).and_return(solvable)
      expect(Cheetah).to receive(:run).with(
        "bash", "-c", "mergesolv #{source_dir}/*",
        :stdout => solvable
      )
      expect(solvable).to receive(:close)
      time = double(File)
      expect(File).to receive(:open).with(
        @kiwi_solv_pool + "/" + @meta.time, "wb"
      ).and_return(time)
      expect(time).to receive(:write).with("static")
      expect(time).to receive(:close)
      info = double(File)
      expect(File).to receive(:open).with(
        @kiwi_solv_pool + "/" + @meta.info, "wb" 
      ).and_return(info)
      expect(info).to receive(:write).with(@uri)
      expect(info).to receive(:close)
      expect(@repo.merge_solv(source_dir)).to eq(@meta.solv)
    end

    it "raises if mergesolv failed" do
      expect(@repo).to receive(:solv_meta).and_return(@meta)
      expect(File).to receive(:exists?).with(@kiwi_solv_pool).and_return(true)
      expect(File).to receive(:open)
      expect(Cheetah).to receive(:run).and_raise(
        Dice::Errors::SolvToolFailed.new(nil)
      )
      expect{ @repo.merge_solv("") }.to raise_error(
        Dice::Errors::SolvToolFailed
      )
    end
  end

  describe "#uptodate?" do
    it "checks a given timestamp against a reference value from file" do
      time_file = @kiwi_solv_pool + "/" + @meta.time
      expect(@repo).to receive(:solv_meta).and_return(@meta)
      expect(File).to receive(:exists?).with(time_file).and_return(true)
      expect(File).to receive(:read).with(time_file).and_return("today")
      expect(@repo.uptodate?("today")).to eq(true)
    end
  end

  describe "#solv_meta" do
    it "returns an OpenStruct with meta information" do
      ref = OpenStruct.new
      ref.solv = "foo"
      ref.time = "foo.timestamp"
      ref.info = "foo.info"
      ref.uri  = @uri
      expect(Digest::MD5).to receive(:hexdigest).with(@uri).and_return("foo")
      expect(@repo.solv_meta).to eq(ref)
    end
  end

  describe "#create_tmpdir" do
    it "creates a tmp dir" do
      expect(Dir).to receive(:mktmpdir).with("dice-solver").and_return("foo")
      expect(@repo.create_tmpdir).to eq("foo")
    end
  end

  describe "#cleanup" do
    it "deletes the tmpdir if stored inside the instance" do
      @repo.instance_variable_set(:@tmp_dir, "foo")
      expect(FileUtils).to receive(:rm_rf).with("foo")
      @repo.cleanup
    end
  end
end
