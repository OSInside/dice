class BuildTask
  attr_reader :buildsystem, :recipe, :screen_job

  def initialize(buildsystem)
    @buildsystem = buildsystem
    @recipe = buildsystem.recipe
    @screen_job = recipe.basepath + "/" + Dice::META + "/" + Dice::SCREEN_JOB
  end

  def run
    if Dice.option.force || !status.uptodate
      buildsystem.set_lock
      buildsystem.up
      buildsystem.provision
      perform_job
      recipe.update
      cleanup
    else
      status.message
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

  def status
    @status ||= BuildStatus.new(buildsystem)
  end
end
