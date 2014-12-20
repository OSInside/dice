class Repository
  class << self
    def solvable(uri)
      repo = nil
      case repotype(uri)
      when Dice::RepoType::RpmMd
        repo = RpmMdRepository.new(uri)
      when Dice::RepoType::SUSE
        repo = SuSERepository.new(uri)
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
  end
end
