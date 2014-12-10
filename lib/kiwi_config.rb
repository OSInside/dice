class KiwiConfig
  attr_reader :xml

  def initialize(description)
    file = File.open(description + "/config.xml")
    @xml = REXML::Document.new file
    file.close
  end

  def repos
    repo_uri = Array.new
    xml.elements.each("*/repository/source") do |element|
      repo_uri << KiwiUri.translate(element.attributes["path"].gsub(/\?.*/,""))
    end
    repo_uri.sort.uniq
  end

  def packages
    packages = Array.new
    xml.elements.each("*/packages/package") do |element|
      packages << element.attributes["name"]
    end
    xml.elements.each("*/packages/namedCollection") do |element|
      packages << "pattern:" + element.attributes["name"]
    end
    packages.sort.uniq
  end
end
