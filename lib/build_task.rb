class BuildTask
  def initialize(recipe)
    Recipe.ok?(recipe)
    @factory = BuildSystemFactory.new(recipe)
    @build_system = @factory.buildsystem
    @repos_solver = @factory.solver
  end

  def build_status
    status = ""
    @repos_solver.writeScan
    if @build_system.is_busy?
      status = Dice::Status::BuildRunning.new
    elsif !@build_system.job_required?
      status = Dice::Status::UpToDate.new
    else
      status = Dice::Status::BuildRequired.new
    end
    status
  end

  def run
    @build_system.up
    @build_system.provision
    run_job
    get_result
    @build_system.writeRecipeChecksum
    @build_system.halt
  end

  def log
    @build_system.get_log
  end

  def cleanup
    @build_system.halt
  end

  private

  def run_job
    @job = @factory.job
    @job.build
  end

  def get_result
    @job.get_result
  end
end
