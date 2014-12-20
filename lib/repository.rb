class Repository
  class << self
    attr_reader :uri

    def solvable(uri)
      @uri = uri
      repo = nil
      case repotype(uri)
      when Dice::RepoType::RpmMd
        repo = rpmmd_repo
      when Dice::RepoType::SUSE
        repo = suse_repo
      end
      repo.solvable
    end

    private

    def repotype(uri)
      repotype = nil
      begin
        open(uri + "/repodata/repomd.xml.key", "rb")
        repotype = Dice::RepoType::RpmMd
      rescue
        open(uri + "/suse/setup/descr/directory.yast", "rb")
        repotype = Dice::RepoType::SUSE
      end
      if !repotype
        raise Dice::Errors::RepoTypeUnknown.new(
          "repo type detection failed for uri: #{uri}"
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
