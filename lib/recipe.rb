class Recipe
  def initialize(description)
    recipe = Pathname.new(description)
    if !File.exists?(recipe) || !File.directory?(recipe.realpath)
      raise Dice::Errors::NoDirectory.new(
        "Need a description directory"
      )
    end
    @basepath = recipe.realpath.to_s
    recipe_ok?
    change_working_dir
  end

  def recipe_ok?
    if !File.file?(@basepath + "/Vagrantfile")
      raise Dice::Errors::NoVagrantFile.new(
        "Need a Vagrantfile"
      )
    end
    if !File.file?(@basepath + "/config.xml")
      raise Dice::Errors::NoKIWIConfig.new(
        "Need a kiwi config.xml"
      )
    end
  end

  def change_working_dir
    Dir.chdir(@basepath)
  end

  def get_basepath
    return @basepath
  end
end
