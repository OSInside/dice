class Repository
  class << self
    def new(uri)
      repo = nil
      begin
        open(uri + "/repodata/repomd.xml.key", "rb")
        repo = RpmMdRepository.new(uri)
      rescue
        repo = SuSERepository.new(uri)
      end
      repo
    end
  end
end
