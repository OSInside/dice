class BuildTask
  def initialize(recipe, options = Hash.new)
    Recipe.ok?(recipe)
    @factory = BuildSystemFactory.new(recipe)
    @buildsystem = @factory.buildsystem
    @options = options
  end

  def build_status
    status = Dice::Status::Unknown.new
    recipe_dir = @buildsystem.get_basepath
    if @buildsystem.is_locked?
      return Dice::Status::BuildRunning.new(self)
    end
    set_lock
    begin
      Solver.writeScan(recipe_dir)
    rescue Dice::Errors::DiceError => e
      release_lock
      raise e
    end
    if @buildsystem.job_required?
      status = Dice::Status::BuildRequired.new(self)
    else
      status = Dice::Status::UpToDate.new(self)
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
      cleanup_screen_job
      @buildsystem.halt
    else
      status.message
    end
  end

  def cleanup_build_error_log
    log_file = error_log_file
    FileUtils.rm(log_file) if File.file?(log_file)
  end

  def cleanup_screen_job
    screen_job = screen_job_file
    FileUtils.rm(screen_job) if File.file?(screen_job)
  end

  def error_log_file
    log_file = @buildsystem.get_basepath + "/" +
      Dice::META + "/" + Dice::BUILD_ERROR_LOG
    log_file
  end

  def screen_job_file
    screen_job = @buildsystem.get_basepath + "/" +
      Dice::META + "/" + Dice::SCREEN_JOB
    screen_job
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
