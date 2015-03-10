class SuSERepository < RepositoryBase
  def solvable
    solv_file = @@kiwi_solv + "/" + meta.solv
    if uptodate?
      return solv_file
    end
    tmp_dir = create_tmpdir
    solv_dir = tmp_dir + "/solv"
    get_pattern_files.each do |pattern|
      curl_file(
        :source => pattern,
        :dest   => tmp_dir + "/" + File.basename(pattern)
      )
    end
    create_solv(
      :tool       => "susetags2solv",
      :source_dir => tmp_dir,
      :dest_dir   => solv_dir
    )
    primary_files = get_primary_files
    primary_files.list.each do |primary|
      curl_file(
        :source => primary,
        :dest   => tmp_dir + "/primary/" + File.basename(primary)
      )
    end
    create_solv(
      :tool       => primary_files.tool,
      :source_dir => tmp_dir + "/primary",
      :dest_dir   => solv_dir
    )
    merge_solv(solv_dir)
    cleanup
    solv_file
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

