class BuildTask
  def initialize(recipe, options = Hash.new)
    @buildsystem = BuildSystemFactory.new(recipe)
    @options = options
    @recipe = recipe
  end

  def build_status
    status = Dice::Status::Unknown.new
    if @buildsystem.is_locked?
      if @buildsystem.is_building?
        return Dice::Status::BuildRunning.new
      else
        return Dice::Status::BuildSystemLocked.new
      end
    end
    solver = Solver.new(@recipe)
    solver.writeScan
    if @recipe.job_required?
      status = Dice::Status::BuildRequired.new
    else
      status = Dice::Status::UpToDate.new
    end
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
      @recipe.writeRecipeChecksum
      release_lock
      cleanup_screen_job
      @buildsystem.halt
    else
      status.message @recipe
    end
  end

  def build_log_file
    log_file = @recipe.get_basepath + "/" +
      Dice::META + "/" + Dice::BUILD_LOG
    log_file
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

  def cleanup_screen_job
    screen_job = screen_job_file
    FileUtils.rm(screen_job) if File.file?(screen_job)
  end

  def perform_job
    job = Job.new(@buildsystem)
    job.build
    job.bundle
    job.get_result
  end
end
