class Solver
  def self.writeScan(description)
    Logger.info(
      "Solving software pattern/packages to check rebuild request"
    )
    solver_info = ""
    begin
      solver_info = Command.run(
        "/usr/sbin/kiwi", "--info", description,
        "--select", "packages", "--logfile", "terminal", :stdout => :capture
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::SolvePackagesFailed.new(
        "kiwi packager solver failed with:\n#{e.stderr}"
      )
    end
    recipe_scan = File.open("#{description}/.dice/scan", "w")
    solver_info.split("\n").each do |line|
      if line =~ /<package/
        recipe_scan.write(line+"\n")
      end
    end
    recipe_scan.close
  end
end
