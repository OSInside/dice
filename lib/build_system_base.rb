class BuildSystemBase
  attr_reader :recipe, :build_log, :lock

  abstract_method :up
  abstract_method :provision
  abstract_method :halt
  abstract_method :get_port
  abstract_method :get_ip
  abstract_method :is_busy?
  abstract_method :get_lockfile

  def initialize(recipe)
    @recipe = recipe
    @build_log = recipe.basepath + "/" + Dice::META + "/" + Dice::BUILD_LOG
    recipe.change_working_dir
    @lock = get_lockfile
  end

  def is_building?
    building = true
    begin
      Command.run("fuser", build_log, :stdout => :capture)
    rescue Cheetah::ExecutionFailed => e
      building = false
    end
    building
  end

  def is_locked?
    File.file?(lock)
  end

  def set_lock
    lockfile = File.new(lock, "w")
    lockfile.close
  end

  def release_lock
    FileUtils.rm(lock) if File.file?(lock)
  end

  def prepare_job
    @job ||= Job.new(self)
  end
end
