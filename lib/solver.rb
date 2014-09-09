class Solve
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @recipe_path = system.get_basepath
    @recipe_solv = @recipe_path + "/config.scan"
    @info_pattern = "/tmp/kiwi-xmlinfo*"
  end

  def writeScan
    cleanup
    begin
      Command.run(
        "sudo", "/usr/sbin/kiwi", "--info", @recipe_path,
        "--select", "packages", "--logfile", "terminal"
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::SolvePackagesFailed.new(
        "kiwi packager solver failed with:\n#{e.stdout}"
      )
    end
    store_to_receipt
  end

  private

  def get_info_files
    return Dir.glob @info_pattern
  end

  def cleanup
    file_list = get_info_files
    file_list.each do |file|
      begin
        Command.run("sudo", "rm", "-f", file)
      rescue Cheetah::ExecutionFailed => e
        raise Dice::Errors::SolveCleanUpFailed.new(
          "Can't remove tmp data: #{e.stderr}"
        )
      end
    end
  end

  def store_to_receipt
    result = get_info_files.first
    recipe_scan = File.open(@recipe_solv, "w")
    begin
      Command.run("sudo", "cat", result, :stdout => recipe_scan)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::SolveCreateRecipeResultFailed.new(
        "Can't create recipe scan result: #{e.stderr}"
      )
    end
  end
end
