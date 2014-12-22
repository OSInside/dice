class BuildSystemBase
  attr_reader :recipe, :build_log, :lock

  abstract_method :up
  abstract_method :provision
  abstract_method :halt
  abstract_method :get_port
  abstract_method :get_ip
  abstract_method :is_busy?

  def initialize(recipe)
    @recipe = recipe
    @build_log = recipe.basepath + "/" + Dice::META + "/" + Dice::BUILD_LOG
    recipe.change_working_dir
    if self.is_a?(HostBuildSystem)
      # set a global lock for the used worker host
      # running multiple builds in parallel on one host is not supported
      # by kiwi. Thus we set a lock for the entire host
      @lock = "/tmp/.lock-" + Dice.config.buildhost
    else
      # set a recipe specific lock
      # building the same recipe multiple times is possible if the
      # buildsystem is a container or a vm but not useful. Thus we
      # prevent that by a recipe lock
      @lock = recipe.basepath + "/" + Dice::META + "/" + Dice::LOCK
    end
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
