class KiwiUri
  class << self
    def translate(uri)
      # normalize url types available in a kiwi configuration into
      # standard mime types. This also includes resolving open build
      # service resource locator into http addresses
      case uri
      when /^obs:\/\/(\d.*)/
        # distribution URL, starting with the number e.g 13.1
        uri = "http://download.opensuse.org/distribution/#{$1}/"
      when /^(\/.*)/
        # Simple path, should be a distribution dir
        uri = "dir://#{$1}/"
      end
      Uri.new(uri)
    end
  end
end
