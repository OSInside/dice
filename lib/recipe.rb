class Recipe
  attr_reader :cwd, :kiwi_config, :description

  def initialize(description)
    @description = description
    @cwd = get_cwd
  end

  def setup
    load_dice_config
    load_kiwi_config
    create_metadir
  end

  def update
    writeRecipeChecksum
  end

  def uptodate?
    writeRecipeScan(kiwi_config.solve_packages)
    cur_digest = readDigest
    new_digest = calculateDigest
    if (cur_digest != new_digest)
      return false
    end
    true
  end

  def change_working_dir
    Dir.chdir(basepath)
  end

  def reset_working_dir
    Dir.chdir(cwd)
  end

  def basepath
    return @basepath if @basepath
    recipe_path = Pathname.new(description)
    if !File.exists?(recipe_path) || !File.directory?(recipe_path.realpath)
      raise Dice::Errors::NoDirectory.new(
        "Given recipe does not exist or is not a directory"
      )
    end
    @basepath = recipe_path.realpath.to_s
  end

  def validate
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
  end

  private

  def get_cwd
    Pathname.new(Dir.pwd).realpath.to_s
  end

  def writeRecipeScan(solver_result)
    recipe_scan = File.open(
      "#{basepath}/#{Dice::META}/#{Dice::SCAN_FILE}", "w"
    )
    recipe_scan.write(JSON.pretty_generate(solver_result))
    recipe_scan.close
  end

  def writeRecipeChecksum
    digest = calculateDigest
    digest_file = File.new(
      basepath + "/" + Dice::META + "/" + Dice::DIGEST_FILE, "w"
    )
    digest_file.puts digest
    digest_file.close
  end

  def create_metadir
    metadir = basepath + "/" + Dice::META
    FileUtils.mkdir(metadir) if !File.directory?(metadir)
  end

  def load_kiwi_config
    @kiwi_config ||= KiwiConfig.new(basepath)
  end

  def load_dice_config
    if diceFile
      load basepath + "/" + Dice::DICE_FILE
    end
  end

  def vagrantFile
    File.file?(basepath + "/" + Dice::VAGRANT_FILE)
  end

  def diceFile
    File.file?(basepath + "/" + Dice::DICE_FILE)
  end

  def kiwiFile
    File.file?(basepath + "/" + Dice::KIWI_FILE)
  end

  def calculateDigest
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
