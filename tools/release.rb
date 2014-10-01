require "erb"
require_relative "spec_template"

class Release
  def initialize(version = Dice::VERSION)
    @release_version = version
    @tag             = "v#{version}"
    @release_time    = Time.now.strftime('%a %b %d %H:%M:%S %Z %Y')
    @gemspec         = Gem::Specification.load("dice.gemspec")
    @mail            = Cheetah.run(
      ["git", "config", "user.email"], :stdout => :capture
    ).chomp
  end

  def prepare
    remove_old_releases
    generate_specfile
    generate_changelog
    copy_rpmlintrc
  end

  private

  def remove_old_releases
    FileUtils.rm Dir.glob(File.join(Dice::ROOT, "package/*"))
  end

  def generate_changelog
    Cheetah.run "#{Dice::ROOT}/.changelog_write"
  end

  def copy_rpmlintrc
    Dir.chdir(Dice::ROOT) do
      FileUtils.cp "dice-rpmlintrc", "package/dice-rpmlintrc"
    end
  end

  def generate_specfile
    Dir.chdir(Dice::ROOT) do
      erb = ERB.new(File.read("dice.spec.erb"), nil, "-")
      env = SpecTemplate.new(@release_version, @gemspec)

      File.open("package/dice.spec", "w+") do |spec_file|
        spec_file.puts erb.result(env.instance_eval { binding })
      end
    end
  end
end
