class SpecTemplate
  attr_accessor   :version
  attr_accessor   :dependencies

  def initialize(version, gemspec)
    @version      = version
    @gemspec      = gemspec
    @dependencies = @gemspec.runtime_dependencies
  end

  def build_requires(options = {})
    @gemspec.runtime_dependencies.flat_map {
      |d| gem_dependency_to_rpm_requires(d)
    }.flatten
  end

  private

  def gem_dependency_to_rpm_requires(dependency)
    name = dependency.name

    dependency.requirement.requirements.map do |operator, version|
      case operator
        when "!="
          [
            { :name => name, :operator => "<", :version => version },
            { :name => name, :operator => ">", :version => version }
          ]
        when "~>"
          if version.to_s.split(".").size > 1
            [
              { :name => name, :operator => ">=", :version => version },
              { :name => name, :operator => "<=", :version => version.bump }
            ]
          else
            { :name => name }
          end
        else
          { :name => name, :operator => operator, :version => version }
      end
    end
  end
end
