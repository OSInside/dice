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
    system("#{$0} build #{recipe}")
  end
end

