class Repository
  class << self
    attr_reader :uri

    def solvable(uri)
      @uri = uri
      repo = nil
      case repotype
      when Dice::RepoType::RpmMd
        repo = rpmmd_repo
      when Dice::RepoType::SUSE
        repo = suse_repo
      end
      repo.solvable
    end

    private

    def repotype
      # We use the uri.name as location because because ruby's
      # open-uri implementation understands remote mime types
      location = uri.name

      if uri.is_iso?
        location = uri.map_loop
      end

      lookup_locations = Hash.new
      lookup_locations["/suse/setup/descr/directory.yast"] =
        Dice::RepoType::SUSE
      lookup_locations["/repodata/repomd.xml.key"] =
        Dice::RepoType::RpmMd

      repotype = nil
      lookup_locations.each do |indicator, type|
        begin
          handle = open(location + indicator, "rb")
          repotype = type
          handle.close
        rescue
          # ignore if open failed, result handled later
        end
      end

      if uri.is_iso?
        uri.unmap_loop
      end

      if !repotype
        raise Dice::Errors::RepoTypeUnknown.new(
          "repo type detection failed for uri: #{uri.name}"
        )
      end
      repotype
    end

    def rpmmd_repo
      RpmMdRepository.new(uri)
    end

    def suse_repo
      SuSERepository.new(uri)
    end
  end
end
