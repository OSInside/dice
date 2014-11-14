class RepositoryFactory
  class << self
    def new(uri)
      repo = nil
      begin
        File.open(uri + "/repodata/repomd.xml.key", "rb")
        repo = RpmMdRepository.new(uri)
      rescue
        repo = SuSERepository.new(uri)
      end
      repo
    end
  end
end
