class KiwiUri
  class << self
    def translate(args)
      # normalize url types available in a kiwi configuration into
      # standard mime types. This also includes resolving open build
      # service resource locator into http addresses
      if args[:repo_type] == "yast2"
        # distribution URL pointing to a yast distro repo
        bs_project = args[:name].gsub(/obs:\/\//, "")
        args[:name] = "http://download.opensuse.org/distribution/#{bs_project}/"
      else
        case args[:name]
          when /^obs:\/\/(\d.*)/
            # distribution URL pointing to a rpm-md distro repo
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
