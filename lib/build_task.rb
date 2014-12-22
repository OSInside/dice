class BuildTask
  attr_reader :buildsystem, :recipe, :screen_job

  def initialize(buildsystem)
    @buildsystem = buildsystem
    @recipe = buildsystem.recipe
    @screen_job = recipe.basepath + "/" + Dice::META + "/" + Dice::SCREEN_JOB
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
      buildsystem.set_lock
      buildsystem.up
      buildsystem.provision
      perform_job
      recipe.update
      cleanup
    else
      status.message(recipe)
    end
  end

  def log
    buildsystem.get_log
  end

  def cleanup
    buildsystem.release_lock
    FileUtils.rm(screen_job) if File.file?(screen_job)
    buildsystem.halt
  end

  private

  def perform_job
    job = buildsystem.prepare_job
    job.build
    job.bundle
    job.get_result
  end
end
