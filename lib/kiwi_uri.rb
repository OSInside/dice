class KiwiUri
  class << self
    def translate(uri)
      case uri
      when /^obs:\/\/(\d.*)/
        # distribution URL, starting with the number e.g 13.1
        uri = "http://download.opensuse.org/distribution/#{$1}/"
      when /^http/
        # no translation for http and https required
      else
        raise Dice::Errors::UriTypeUnknown.new(
          "URI style #{uri} unknown"
        )
      end
      uri
    end
  end
end
