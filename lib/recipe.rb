class Recipe
  attr_reader :description, :basepath, :cwd

  def initialize(description)
    @description = description
    recipe = ok?
    @basepath = recipe.realpath.to_s
    @cwd = Pathname.new(Dir.pwd).realpath.to_s
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
    digest_file = File.new(
      basepath + "/" + Dice::META + "/" + Dice::DIGEST_FILE, "w"
    )
    digest_file.puts digest
    digest_file.close
  end

  def change_working_dir
    Dir.chdir(basepath)
  end

  def reset_working_dir
    Dir.chdir(cwd)
  end

  private

  def ok?
    recipe = Pathname.new(description)
    if !File.exists?(recipe) || !File.directory?(recipe.realpath)
      raise Dice::Errors::NoDirectory.new(
        "Given recipe does not exist or is not a directory"
      )
    end
    vagrantFile = File.file?(description + "/" + Dice::VAGRANT_FILE)
    diceFile = File.file?(description + "/" + Dice::DICE_FILE)
    kiwiFile = File.file?(description + "/" + Dice::KIWI_FILE)
    if !kiwiFile
      raise Dice::Errors::NoKIWIConfig.new(
        "No kiwi configuration found"
      )
    end
    if !vagrantFile && !diceFile
      raise Dice::Errors::NoConfigFile.new(
        "No vagrant and/or dice configuration found"
      )
    end
    if diceFile
      load description + "/" + Dice::DICE_FILE
    end
    metadir = recipe.realpath.to_s + "/" + Dice::META
    if !File.directory?(metadir)
      FileUtils.mkdir(metadir)
    end
    recipe
  end

  def createDigest
    result = ""
    recipe_items = Find.find(".")
    recipe_items.each do |item|
      item.gsub!(/^\.\//,'')
      next if File.directory?(item)
      next if item =~ /^\.|^#{Dice::VAGRANT_FILE}$/
      next if item =~ /^\.|^#{Dice::DICE_FILE}$/
      sha256 = Digest::SHA256.file item
      result += item + ":" + sha256.hexdigest + "\n"
    end
    solver_scan = ".dice/scan"
    if File.exists?(solver_scan)
      sha256 = Digest::SHA256.file solver_scan
      result += "scan:" + sha256.hexdigest + "\n"
    end
    result
  end

  def readDigest
    cur_digest = ""
    begin
      cur_digest = File.read(Dice::META + "/" + Dice::DIGEST_FILE)
    rescue
      # continue, working with empty digest is ok
    end
    cur_digest
  end
end
