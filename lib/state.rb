class BuildStatus
  def message(recipe)
    Logger.info("BuildStatus: #{self.class}")
    job_info recipe
    if self.is_a?(Dice::Status::UpToDate)
      result_info recipe
    end
  end

  private

  def job_info(recipe)
    jobs = active_jobs(recipe.get_basepath + "/" +
      Dice::META + "/" + Dice::SCREEN_JOB
    )
    if !jobs.empty?
      Logger.info("--> Screen job: $ screen -r #{jobs.last}")
    end
  end

  def result_info(recipe)
    result_file = recipe.get_basepath + "/" +
      Dice::META + "/" + Dice::BUILD_RESULT
    if File.exists?(result_file)
      Logger.info("--> Build result: tar -tf #{result_file}")
    end
  end

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
