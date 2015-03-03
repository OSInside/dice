class Repository
  class << self
    attr_reader :uri

    def solvable(uri)
      @uri = uri
      repo = nil
      case uri.repo_type
      when Dice::RepoType::RpmMd
        repo = rpmmd_repo
      when Dice::RepoType::SUSE
        repo = suse_repo
      when Dice::RepoType::PlainDir
        repo = plaindir_repo
      else
        raise Dice::Errors::RepoTypeUnknown.new(
          "repo type #{uri.repo_type} unknown for uri: #{uri.name}"
        )
      end
      repo.solvable
    end

    private

    def rpmmd_repo
      RpmMdRepository.new(uri)
    end

    def suse_repo
      SuSERepository.new(uri)
    end

    def plaindir_repo
      PlainDirRepository.new(uri)
    end
  end
end
