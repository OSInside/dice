class SuSERepository < RepositoryBase
  attr_reader :meta

  def initialize(uri)
    super(uri)
    @meta = solv_meta
  end

  def solvable
    solvable = @@kiwi_solv + "/" + meta.solv
    if uptodate?
      return solvable
    end
    tmp_dir = create_tmpdir
    solv_dir = tmp_dir + "/solv"
    get_pattern_files.each do |pattern|
      curl_file(pattern, tmp_dir + "/" + File.basename(pattern))
    end
    create_solv("susetags2solv", tmp_dir, solv_dir)
    primary_files = get_primary_files
    primary_files.list.each do |primary|
      curl_file(primary, tmp_dir + "/primary/" + File.basename(primary))
    end
    create_solv(primary_files.tool, tmp_dir + "/primary", solv_dir)
    merge_solv(solv_dir)
    cleanup
    solvable
  end

  private

  def get_pattern_files
    result = []
    patterns = []
    patbase = "suse/setup/descr"
    begin
      patterns = load_file(patbase + "/patterns").split("\n")
    rescue
      # the patterns file exists only on older repos. newer suse
      # versions implementes patterns with rpm packages
      return result
    end
    patterns.each do |pat|
      patfile = patbase + "/" + pat
      result << patfile
    end
    result
  end

  def get_primary_files
    result = OpenStruct.new
    begin
      result.tool = "rpmmd2solv"
      result.list = []
      xml = REXML::Document.new(load_file("suse/repodata/repomd.xml"))
      xml.elements.each("repomd/data[@type='primary']/location") do |e|
        href = e.attribute("href").to_s
        result.list << "suse/" + href
      end
    rescue
      result.tool = "susetags2solv"
      result.list = ["suse/setup/descr/packages.gz"]
    end
    result
  end
end

