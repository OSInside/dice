class BuildStatus
  attr_reader :running, :locked, :recipe, :uptodate, :buildsystem

  def initialize(buildsystem)
    @buildsystem = buildsystem
    @recipe = buildsystem.recipe
    @running = false
    @locked  = false
    @uptodate = false
    init_status
  end

  def message
    status_info
    active_job_info
    build_result_info
  end

  def rebuild?
    rebuild = false
    if locked
      # never start a build on a locked build system
      return rebuild
    end
    if Dice.option.force
      rebuild = true
    end
    if !uptodate
      rebuild = true
    end
    rebuild
  end

  private

  def init_status
    if buildsystem.is_locked?
      @locked = true
      @running = buildsystem.is_building?
    else
      @uptodate = recipe.uptodate?
    end
  end

  def status_info
    if running
      Dice.logger.info("BuildStatus: BuildRunning")
    elsif locked
      Dice.logger.info("BuildStatus: BuildSystemLocked")
    elsif uptodate
      Dice.logger.info("BuildStatus: UpToDate")
    else
      Dice.logger.info("BuildStatus: BuildRequired")
    end
  end

  def active_job_info
    jobs = active_jobs(recipe.basepath + "/" +
      Dice::META + "/" + Dice::SCREEN_JOB
    )
    if !jobs.empty?
      Dice.logger.info("--> Screen job: $ screen -r #{jobs.last}")
    end
  end

  def build_result_info
    return if !uptodate
    result_file = recipe.basepath + "/" +
      Dice::META + "/" + Dice::BUILD_RESULT
    if File.exists?(result_file)
      Dice.logger.info("--> Build result: tar -tf #{result_file}")
    end
  end

  def active_jobs(job_file)
    active = []
    begin
      File.open(job_file).each do |job_name|
        job_name = job_name.chomp
        active << job_name if active_job?(job_name)
      end
    rescue
      # ignore if job file does not exist or can't be opened
    end
    active
  end

  def active_job?(job_name)
    begin
      Command.run("screen", "-X", "-S", job_name, "info")
    rescue Cheetah::ExecutionFailed => e
      return false
    end
    return true
  end
end
