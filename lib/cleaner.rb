class Cleaner
  attr_reader :buildsystem

  def initialize(buildsystem)
    @buildsystem = buildsystem
  end

  def clean_stale_lock
    if buildsystem.is_building?
      raise Dice::Errors::ActiveSemaphoreLock.new(
        "Buildsystem runs an active job, will not remove active lock"
      )
    end
    key = buildsystem.set_lock
    Dice.logger.info("Deleting Semaphore Key: 0x#{key.to_s(16)}")
    buildsystem.release_lock
  end
end
