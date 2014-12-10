class BuildScheduler
  def self.run_tasks(dir)
    dir_list = Dir.glob("#{dir}/*")
    if dir_list.empty?
      raise Dice::Errors::NoDirectory.new(
        "No description directories found below: #{dir}"
      )
    end
    dir_list.sort.each do |description|
      recipe = Recipe.new(description)
      fork do
        run recipe.basepath
      end
    end
  end

  private

  def self.run(description)
    job_name = set_job_name
    job_started = true
    Logger.info("#{self}: Starting build job: #{job_name}")
    build_cmd = [$0, "build", description]
    screen_cmd = ["screen", "-S", job_name, "-d", "-m"]
    begin
      Command.run(screen_cmd + build_cmd)
    rescue Cheetah::ExecutionFailed => e
      job_started = false
    end
    if job_started
      FileUtils.mkdir_p(description + "/" + Dice::META)
      job_info = File.new(
        description + "/" + Dice::META + "/" + Dice::SCREEN_JOB, "a+"
      )
      job_info.puts(job_name)
      job_info.close
    end
  end

  private

  def self.set_job_name
    job_name = "dice-" + (0...8).map { (65 + Kernel.rand(26)).chr }.join
    job_name
  end
end
