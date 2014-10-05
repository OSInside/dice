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
    run_ok = true
    error_log = recipe + "/.dice/build_error.log"
    begin
      Logger.set_recipe_dir(Pathname.new(recipe).basename)
      Logger.info "Starting build task"
      task = BuildTask.new(recipe)
      task.run
    rescue Dice::Errors::DiceError => e
       Logger.error(e.message, error_log)
       run_ok = false
    end
    run_ok
  end
end

