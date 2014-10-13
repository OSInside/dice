class BuildStatus
  def initialize(build_task = nil)
    @build_task = build_task
  end

  def message
    Logger.info("Build-System status is: #{self.class}")
    if @build_task
      job_file = @build_task.screen_job_file
      jobs = active_jobs(job_file)
      if !jobs.empty?
        Logger.info(
          "--> Screen job: $ screen -r #{jobs.last}"
        )
      end
    end
  end

  private

  def active_jobs(job_file)
    active = Array.new
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

module Dice
  module Status
    class Unknown < BuildStatus; end
    class BuildRunning < BuildStatus; end
    class BuildSystemLocked < BuildStatus; end
    class UpToDate < BuildStatus; end
    class BuildRequired < BuildStatus; end
  end
end
