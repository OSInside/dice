class Job
  attr_reader :job_user, :job_ssh_private_key
  attr_reader :build_log, :archive, :buildsystem, :ip, :port

  def initialize(buildsystem)
    @buildsystem = buildsystem
    @job_user = Dice.config.ssh_user
    @job_ssh_private_key = Dice.config.ssh_private_key
    @build_log = buildsystem.recipe.basepath + "/" +
      Dice::META + "/" + Dice::BUILD_LOG
    @archive  = buildsystem.recipe.basepath + "/" +
      Dice::META + "/" + Dice::BUILD_RESULT
    @ip = buildsystem.get_ip
    @port = buildsystem.get_port
  end

  def build
    prepare_build
    Dice.logger.info("#{self.class}: Building...")
    build_opts = "--build /vagrant -d /tmp/image --logfile terminal"
    if Dice.option.kiwitype
      build_opts += " --type #{Dice.option.kiwitype}"
    end
    logfile = File.open(build_log, "w")
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", port,
        "-i", job_ssh_private_key, "#{job_user}@#{ip}",
        "sudo /usr/sbin/kiwi #{build_opts}",
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Build failed")
      logfile.close
      buildsystem.halt
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
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", port,
        "-i", job_ssh_private_key, "#{job_user}@#{ip}",
        "sudo /usr/sbin/kiwi #{bundle_opts}",
        :stdout => logfile,
        :stderr => logfile
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Bundler failed")
      logfile.close
      buildsystem.halt
      raise Dice::Errors::BuildFailed.new(
        "Bundle result failed for details check: #{build_log}"
      )
    end
    logfile.close
  end

  def get_result
    Dice.logger.info("#{self.class}: Retrieving results in #{archive}...")
    result = File.open(archive, "w")
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", port,
        "-i", job_ssh_private_key, "#{job_user}@#{ip}",
        "sudo tar --exclude image-root -C /tmp/bundle -c .",
        :stdout => result
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Archiving failed")
      result.close
      buildsystem.halt
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
    begin
      Command.run(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", port,
        "-i", job_ssh_private_key, "#{job_user}@#{ip}",
        "sudo rm -rf /tmp/image /tmp/bundle"
      )
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.info("#{self.class}: Preparation failed")
      buildsystem.halt
      raise Dice::Errors::PrepareBuildFailed.new(
        "Preparing build environment failed with: #{e.stderr}"
      )
    end
  end
end
