class BuildScheduler
  def self.run_tasks(recipe_dir)
    dir_list = Dir.glob("#{recipe_dir}/*")
    dir_list.sort.each do |recipe|
      fork do
        run recipe
      end
    end
  end

  private

  def self.run(recipe)
    job_name = set_job_name
    job_started = true
    Logger.set_recipe_dir(Pathname.new(recipe).basename)
    Logger.info("Starting build job: #{job_name}")
    build_cmd = [$0, "build", recipe]
    screen_cmd = ["screen", "-S", job_name, "-d", "-m"]
    begin
      Command.run(screen_cmd + build_cmd)
    rescue Cheetah::ExecutionFailed => e
      job_started = false
    end
    if job_started
      FileUtils.mkdir_p(recipe + "/.dice")
      job_info = File.new(recipe + "/.dice/job", "a+")
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
