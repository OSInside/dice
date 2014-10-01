class BuildTask
  def initialize(recipe)
    Recipe.ok?(recipe)
    @factory = BuildSystemFactory.new(recipe)
  end

  def build_status
    status = Dice::Status::Unknown.new
    Solver.writeScan
    if @factory.buildsystem.is_busy?
      status = Dice::Status::BuildRunning.new
    elsif !@factory.buildsystem.job_required?
      status = Dice::Status::UpToDate.new
    else
      status = Dice::Status::BuildRequired.new
    end
    status
  end

  def run
    @factory.buildsystem.up
    @factory.buildsystem.provision
    perform_job
    @factory.buildsystem.writeRecipeChecksum
    @factory.buildsystem.halt
  end

  def log
    @factory.buildsystem.get_log
  end

  def cleanup
    @factory.buildsystem.halt
  end

  private

  def perform_job
    job = @factory.job
    job.build
    job.bundle
    job.get_result
  end
end
