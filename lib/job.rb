class Job
  attr_reader :build_log, :archive, :buildsystem

  def initialize(buildsystem)
    @buildsystem = buildsystem
    @build_log = buildsystem.recipe.basepath + "/" +
      Dice::META + "/" + Dice::BUILD_LOG
    @archive  = buildsystem.recipe.basepath + "/" +
      Dice::META + "/" + Dice::BUILD_RESULT
  end

  def build
    prepare_build
    Dice.logger.info("#{self.class}: Building...")
    build_opts = "--build /vagrant -d /tmp/image --logfile terminal"
    if Dice.option.kiwitype
      build_opts += " --type #{Dice.option.kiwitype}"
    end
    if Dice.option.kiwiprofile
      build_opts += " --add-profile #{Dice.option.kiwiprofile}"
    end
    logfile = File.open(build_log, "w")
    kiwi_command = ["sudo /usr/sbin/kiwi #{build_opts}"]
    begin
      Command.run(
        buildsystem.job_builder_command | kiwi_command,
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Build failed")
      logfile.close
      raise Dice::Errors::BuildFailed.new(
        "Build failed for details check: #{build_log}"
      )
    end
    logfile.close
  end

  def bundle
    Dice.logger.info("#{self.class}: Bundle results...")
    logfile = File.open(build_log, "a")
    bundle_opts = "--bundle-build /tmp/image --bundle-id DiceBuild " +
      "--destdir /tmp/bundle --logfile terminal"
    kiwi_command = ["sudo /usr/sbin/kiwi #{bundle_opts}"]
    begin
      Command.run(
        buildsystem.job_builder_command | kiwi_command,
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Bundler failed")
      logfile.close
      raise Dice::Errors::BuildFailed.new(
        "Bundle result failed for details check: #{build_log}"
      )
    end
    logfile.close
  end

  def get_result
    Dice.logger.info("#{self.class}: Retrieving results in #{archive}...")
    result = File.open(archive, "w")
    result_command = ["sudo tar --exclude image-root -C /tmp/bundle -c ."]
    begin
      Command.run(
        buildsystem.job_builder_command | result_command,
        :stdout => result
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Archiving failed")
      result.close
      raise Dice::Errors::ResultRetrievalFailed.new(
        "Archiving result failed with: #{e.stderr}"
      )
    end
    result.close
  end

  private

  def prepare_build
    Dice.logger.info("#{self.class}: Preparing build...")
    FileUtils.rm(archive) if File.file?(archive)
    prepare_command = [
      "sudo rm -rf /tmp/image /tmp/bundle /var/lock/kiwi-init.lock"
    ]
    begin
      Command.run(
        buildsystem.job_builder_command | prepare_command
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Preparation failed")
      raise Dice::Errors::PrepareBuildFailed.new(
        "Preparing build environment failed with: #{e.stderr}"
      )
    end
  end
end
