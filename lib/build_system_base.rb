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
    if semaphore.getval(semaphore_id) >= 1
      return true
    end
    false
  end

  def set_lock
    semaphore.setval(semaphore_id, 1)
  end

  def release_lock
    semaphore.remove(semaphore_id)
  end

  def prepare_job
    @job ||= Job.new(self)
  end

  private

  def semaphore_id
    @semaphore_id ||= get_semaphore
  end

  def semaphore
    @semaphore ||= Semaphore.new
  end

  def get_semaphore
    id = semaphore.semget(lock.sum)
    if (id < 0)
      raise Dice::Errors::SemaphoreSemGetFailed.new(
        "Can't create semaphore: semget returned #{id}"
      )
    end
    id
  end
end
