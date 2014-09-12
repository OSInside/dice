class BuildTask
  def initialize(recipe, buildhost = nil)
    @build_system = nil
    if !buildhost
      @build_system = VagrantBuildSystem.new(recipe)
    else
      @build_system = HostBuildSystem.new(recipe)
    end
    @repos_solver = Solve.new(@build_system)
  end

  def build_status
    status = ""
    @repos_solver.writeScan
    if @build_system.is_locked?
      status = Dice::Status::Locked.new
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

  private

  def run_job
    @job = Job.new(@build_system)
    @job.build
  end

  def get_result
    @job.get_result
  end
end
