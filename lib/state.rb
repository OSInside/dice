class BuildStatus
  def initialize(build_task = nil)
    @build_task = build_task
  end

  def message
    Logger.info("Build-System status is: #{self.class}")
    if @build_task
      log_file = @build_task.error_log_file
      job_file = @build_task.screen_job_file
      if File.file?(job_file)
# TODO: check with screen -X -S job info if the job really still exists
        Logger.info(
          "--> Screen job exists, details: #{job_file}"
        )
      end
      if File.file?(log_file)
        Logger.info(
          "--> Last build attempt failed, details: #{log_file}"
        )
      end
    end
  end
end

module Dice
  module Status
    class Unknown < BuildStatus; end
    class BuildRunning < BuildStatus; end
    class UpToDate < BuildStatus; end
    class BuildRequired < BuildStatus; end
  end
end
