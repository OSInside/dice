class KiwiUri
  class << self
    def translate(args)
      # normalize url types available in a kiwi configuration into
      # standard mime types. This also includes resolving open build
      # service resource locator into http addresses
      case args[:name]
      when /^obs:\/\/(\d.*)/
        # distribution URL, starting with the number e.g 13.1
        args[:name] = "http://download.opensuse.org/distribution/#{$1}/"
      when /^obs:\/\/update\/(\d.*)/
        # distribution update URL
        args[:name] = "http://download.opensuse.org/update/#{$1}/"
      when /^(\/.*)/
        # Simple path, should be a distribution dir
        args[:name] = "dir://#{$1}/"
      end
      Uri.new(args)
    end
  end
end
