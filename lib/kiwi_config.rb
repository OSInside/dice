class KiwiConfig
  attr_reader :xml

  def initialize(description)
    file = File.open(description + "/config.xml")
    @xml = REXML::Document.new file
    file.close
  end

  def repos
    repo_uri = []
    xml.elements.each("*/repository") do |repo|
      repo_type = repo.attributes["type"]
      user = repo.attributes["username"]
      pass = repo.attributes["password"]
      repo.elements.each("source") do |element|
        source_path = element.attributes["path"].gsub(/\?.*/,"")
        repo_uri << KiwiUri.translate(
          :name => source_path, :repo_type => repo_type,
          :user => user, :pass => pass
        )
      end
    end
    repo_uri
  end

  def packages
    packages = []
    xml.elements.each("*/packages/package") do |element|
      packages << element.attributes["name"]
    end
    xml.elements.each("*/packages/namedCollection") do |element|
      packages << "pattern:" + element.attributes["name"]
    end
    packages.sort.uniq
  end

  def solve_packages
    package_solver.solve
  end

  private

  def package_solver
    @package_solver ||= Solver.new(self)
  end
end
