class PlainDirRepository < RepositoryBase
  attr_reader :meta

  def initialize(uri)
    super(uri)
    @meta = solv_meta
  end

  def solvable
    solv_file = @@kiwi_solv + "/" + meta.solv
    tmp_dir = create_tmpdir
    package_list = Dir.glob("#{uri.location}/*")
    package_list.each do |package_file|
      package_base_name = File.basename(package_file)
      curl_file(
        :source => package_base_name,
        :dest   => tmp_dir + "/" + package_base_name
      )
    end
    solv_dir = tmp_dir + "/solv"
    create_solv(
      :tool       => "rpms2solv",
      :source_dir => tmp_dir,
      :dest_dir   => solv_dir
    )
    merge_solv(solv_dir)
    cleanup
    solv_file
  end
end

