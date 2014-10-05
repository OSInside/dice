class Recipe
  @@digest = ".checksum.sha256"

  def initialize(description)
    recipe = Pathname.new(description)
    @basepath = recipe.realpath.to_s
    @cwd = Pathname.new(Dir.pwd).realpath.to_s
  end

  def self.ok?(description)
    recipe = Pathname.new(description)
    Logger.set_recipe_dir(recipe.basename)
    if !File.exists?(recipe) || !File.directory?(recipe.realpath)
      raise Dice::Errors::NoDirectory.new(
        "Given recipe does not exist or is not a directory"
      )
    end
    vagrantFile = File.file?(description + "/Vagrantfile")
    diceFile = File.file?(description + "/Dicefile")
    kiwiFile = File.file?(description + "/config.xml")
    if !kiwiFile
      raise Dice::Errors::NoKIWIConfig.new(
        "No kiwi config.xml found"
      )
    end
    if !vagrantFile && !diceFile
      raise Dice::Errors::NoConfigFile.new(
        "No Vagrantfile or Dicefile found"
      )
    end
    if diceFile
      load description + "/Dicefile"
    end
    true
  end

  def job_required?
    cur_digest = readDigest
    new_digest = createDigest
    if (cur_digest != new_digest)
      return true
    end
    false
  end

  def writeRecipeChecksum
    digest = createDigest
    digest_file = File.new(@basepath+@@digest, "w")
    digest_file.puts digest
    digest_file.close
  end

  def change_working_dir
    Dir.chdir(@basepath)
  end

  def reset_working_dir
    Dir.chdir(@cwd)
  end

  def get_basepath
    @basepath
  end

  private

  def createDigest
    result = ""
    recipe_items = Find.find(".")
    recipe_items.each do |item|
      item.gsub!(/^\.\//,'')
      next if File.directory?(item)
      next if item =~ /^\.|^Vagrantfile$/
      next if item =~ /^\.|^Dicefile$/
      sha256 = Digest::SHA256.file item
      result += item + ":" + sha256.hexdigest + "\n"
    end
    result
  end

  def readDigest
    cur_digest = ""
    begin
      cur_digest = File.read(@@digest)
    rescue
      # continue, working with empty digest is ok
    end
    cur_digest
  end
end
