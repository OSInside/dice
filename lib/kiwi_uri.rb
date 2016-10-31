class KiwiUri
  class << self
    def translate(args)
      # normalize url types available in a kiwi configuration into
      # standard mime types. This also includes resolving open build
      # service resource locator into http addresses
      if args[:repo_type] == "yast2"
        case args[:name]
          when /^obs:\/\/(.*)/
            # obs distribution URL pointing to a yast distro repo
            args[:name] = "http://download.opensuse.org/distribution/#{$1}/"
        end
      else
        case args[:name]
          when /^obs:\/\/(\d.*)/
            # obs distribution URL pointing to a rpm-md distro repo
            args[:name] = "http://download.opensuse.org/distribution/#{$1}/"
          when /^obs:\/\/(.*)/
            # obs url, translate to http url
            bs_path = $1.gsub(/:/, ":/")
            bs_path = bs_path.gsub(/:\/\//, ":/")
            args[:name] = "http://download.opensuse.org/repositories/#{bs_path}"
          when /^(\/.*)/
            # Simple path, should be a distribution dir
            args[:name] = "dir://#{$1}/"
        end
      end
      RepoUri.new(args)
    end
  end
end
