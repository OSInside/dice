class RpmMdRepository < RepositoryBase
  def initialize(uri)
    super(uri)
    @meta = solv_meta
    @rxml = get_repoxml
  end

  def solvable
    solv_file = @@kiwi_solv + "/" + @meta.solv
    time = timestamp
    if uptodate?(time)
      return solv_file
    end
    tmp_dir = create_tmpdir
    get_repomd_files.each do |repo_file|
      curl_file(repo_file, tmp_dir + "/" + File.basename(repo_file))
    end
    solv_dir = tmp_dir + "/solv"
    create_solv("rpmmd2solv", tmp_dir, solv_dir)
    merge_solv(solv_dir, time)
    cleanup
    solv_file
  end

  private

  def get_repoxml
    REXML::Document.new(load_file("repodata/repomd.xml"))
  end

  def timestamp
    time = ""
    @rxml.elements.each("repomd/data[@type='primary']/timestamp") do |e|
      time = e.text
    end
    time
  end

  def get_repomd_files
    result = Array.new
    types = ["primary", "patterns"]
    types.each do |type|
      @rxml.elements.each("repomd/data[@type='#{type}']/location") do |e|
        href = e.attribute("href").to_s
        result << href
      end
    end
    result
  end
end

