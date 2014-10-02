class BuildTask
  def initialize(recipe)
    Recipe.ok?(recipe)
    @factory = BuildSystemFactory.new(recipe)
    @buildsystem = @factory.buildsystem
    @job = @factory.job
  end

  def build_status
    status = Dice::Status::Unknown.new
    if @buildsystem.is_busy?
      return Dice::Status::BuildRunning.new
    end
    set_lock
    Solver.writeScan
    if !@buildsystem.job_required?
      status = Dice::Status::UpToDate.new
    else
      status = Dice::Status::BuildRequired.new
    end
    status
  end

  def run
    set_lock
    @buildsystem.up
    @buildsystem.provision
    perform_job
    @buildsystem.writeRecipeChecksum
    release_lock
    @buildsystem.halt
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
    @job.build
    @job.bundle
    @job.get_result
  end
end
