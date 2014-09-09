class Solve
  def initialize(system)
    if !system.is_a?(BuildSystem)
      raise
    end
    @recipe_path = system.get_basepath
    @recipe_solv = @recipe_path + "/config.scan"
  end

  def writeScan
    solver_info = ""
    begin
      solver_info = Command.run(
        "sudo", "/usr/sbin/kiwi", "--info", @recipe_path,
        "--select", "packages", "--logfile", "terminal", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::SolvePackagesFailed.new(
        "kiwi packager solver failed with:\n#{e.stdout}"
      )
    end
    store_to_receipt(solver_info)
  end

  private

  def store_to_receipt(solver_info)
    recipe_scan = File.open(@recipe_solv, "w")
    solver_info.split("\n").each do |line|
      if line =~ /<package/
        recipe_scan.write(line+"\n")
      end
    end
    recipe_scan.close
  end
end
