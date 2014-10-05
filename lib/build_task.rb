class BuildTask
  def initialize(recipe, options = Hash.new)
    Recipe.ok?(recipe)
    @factory = BuildSystemFactory.new(recipe)
    @buildsystem = @factory.buildsystem
    @options = options
  end

  def recipe_dir
    @buildsystem.get_basepath
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
    if !@buildsystem.job_required?
      status = Dice::Status::UpToDate.new
    else
      status = Dice::Status::BuildRequired.new
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
    error_log = Cli.error_log_from_task
    if error_log && File.file?(error_log)
      FileUtils.rm(error_log)
    end
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
