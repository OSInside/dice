class BuildTask
  def initialize(recipe, options = Hash.new)
    Recipe.ok?(recipe)
    @factory = BuildSystemFactory.new(recipe)
    @buildsystem = @factory.buildsystem
    @options = options
  end

  def build_status
    status = Dice::Status::Unknown.new
    if @buildsystem.is_busy?
      return Dice::Status::BuildRunning.new
    end
    set_lock
    begin
      Solver.writeScan(@buildsystem.get_basepath)
    rescue Dice::Errors::DiceError => e
      release_lock
      raise e
    end
    log = error_log
    if @buildsystem.job_required?
      status = Dice::Status::BuildRequired.new
    elsif log && File.file?(log)
      status = Dice::Status::BuildErrorExists.new(log)
    else
      status = Dice::Status::UpToDate.new
    end
    release_lock
    status
  end

  def run
    status = Dice::Status::BuildRequired.new
    if !@options["force"]
      status = build_status
    end
    if status.is_a?(Dice::Status::BuildRequired)
      set_lock
      @buildsystem.up
      @buildsystem.provision
      perform_job
      @buildsystem.writeRecipeChecksum
      release_lock
      cleanup_build_error_log
      @buildsystem.halt
    else
      status.message
    end
  end

  def cleanup_build_error_log
    log = error_log
    if log && File.file?(log)
      FileUtils.rm(log)
    end
  end

  def error_log
    recipe_dir = @buildsystem.get_basepath
    error_log = recipe_dir + "/.dice/build_error.log"
    error_log
  end

  def log
    @buildsystem.get_log
  end

  def set_lock
    @buildsystem.set_lock
  end

  def release_lock
    @buildsystem.release_lock
  end

  def cleanup
    release_lock
    @buildsystem.halt
  end

  private

  def perform_job
    job = @factory.job
    job.build
    job.bundle
    job.get_result
  end
end
