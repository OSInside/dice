class KiwiUri
  class << self
    def translate(args)
      # normalize url types available in a kiwi configuration into
      # standard mime types. This also includes resolving open build
      # service resource locator into http addresses
      case args[:name]
      when /^obs:\/\/(\d.*)/
        # distribution URL pointing to a yast distro repo
        args[:name] = "http://download.opensuse.org/distribution/#{$1}/"
      when /^obs:\/\/(.*)/
        # obs url, translate to http url
        bs_path = $1.gsub(/:/, ":/")
        args[:name] = "http://download.opensuse.org/repositories/#{bs_path}"
      when /^(\/.*)/
        # Simple path, should be a distribution dir
        args[:name] = "dir://#{$1}/"
      end
      Uri.new(args)
    end
  end
end
