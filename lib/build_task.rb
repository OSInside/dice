class BuildTask
  attr_reader :buildsystem, :recipe

  def initialize(recipe)
    @buildsystem = BuildSystemFactory.new(recipe)
    @recipe = recipe
  end

  def build_status
    status = Dice::Status::Undefined.new
    if buildsystem.is_locked?
      if buildsystem.is_building?
        return Dice::Status::BuildRunning.new
      else
        return Dice::Status::BuildSystemLocked.new
      end
    end
    if !recipe.uptodate?
      status = Dice::Status::BuildRequired.new
    else
      status = Dice::Status::UpToDate.new
    end
    status
  end

  def run
    status = Dice::Status::BuildRequired.new
    if !Dice.option.force
      status = build_status
    end
    if status.is_a?(Dice::Status::BuildRequired)
      set_lock
      buildsystem.up
      buildsystem.provision
      perform_job
      recipe.update
      release_lock
      cleanup_screen_job
      buildsystem.halt
    else
      status.message @recipe
    end
  end

  def log
    buildsystem.get_log
  end

  def set_lock
    buildsystem.set_lock
  end

  def release_lock
    buildsystem.release_lock
  end

  def cleanup
    release_lock
    buildsystem.halt
  end

  private

  def cleanup_screen_job
    screen_job = recipe.basepath + "/" +
      Dice::META + "/" + Dice::SCREEN_JOB
    FileUtils.rm(screen_job) if File.file?(screen_job)
  end

  def perform_job
    job = Job.new(buildsystem)
    job.build
    job.bundle
    job.get_result
  end
end
