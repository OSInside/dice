class KiwiUri
  class << self
    def translate(uri)
      case uri
      when /^obs:\/\/(\d.*)/
        # distribution URL, starting with the number e.g 13.1
        uri = "http://download.opensuse.org/distribution/#{$1}/"
      when /^dir:\/\/(.*)/
        # distribution repo path, use the main path
        uri = "#{$1}"
      when /^(\/.*)/
        # no translation for simple path starting with a /
      when /^http/
        # no translation for http and https required
        # open-uri has a mime type for that
      else
        raise Dice::Errors::UriTypeUnknown.new(
          "URI style #{uri} unknown"
        )
      end
      uri
    end
  end
end
