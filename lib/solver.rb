class Solver
  def initialize(recipe)
    @description = recipe.get_basepath
    @kiwi = KiwiConfig.new(@description)
  end

  def writeScan
    Logger.info("Solver: Checking for repository updates")
    solver_result = solve
    solve_errors(solver_result.problems)
    solve_json = solve_result(solver_result.transaction)
    recipe_scan = File.open(
      "#{@description}/#{Dice::META}/#{Dice::SCAN_FILE}", "w"
    )
    recipe_scan.write(JSON.pretty_generate(solve_json))
    recipe_scan.close
  end

  def solve_result(transaction)
    result = Array.new
    transaction.newpackages.each do |solvable|
      package = Hash.new
      details = Hash.new
      details[:url] = solvable.repo.name
      details[:installsize] = solvable.lookup_num(Solv::SOLVABLE_INSTALLSIZE)
      details[:arch] = solvable.lookup_str(Solv::SOLVABLE_ARCH)
      details[:evr] = solvable.lookup_str(Solv::SOLVABLE_EVR)
      details[:checksum] = solvable.lookup_checksum(Solv::SOLVABLE_CHECKSUM)
      name = solvable.lookup_str(Solv::SOLVABLE_NAME)
      package[name] = details
      result << package
    end
    result
  end

  def solve_errors(problems)
    if !problems.empty?
      info = {
        :problems => { :count => problems.count, :problem => [] },
        :solutions =>{ :solution => [] }
      }
      problems.each do |p|
        problem = { :id => p.id, :message => p.findproblemrule.info.problemstr }
        info[:problems][:problem] << problem
        p.solutions.each do |s|
          solution = { :id => s.id, :options => [] }
          s.elements(1).each do |e|
            solution[:options] << e.str
          end
          info[:solutions][:solution] << solution
        end
      end
      raise Dice::Errors::SolvJobFailed.new(
        "Solver problems: #{JSON.pretty_generate(info)}"
      )
    end
  end

  private

  def solve
    result = OpenStruct.new
    pool = setup_pool
    solver = pool.Solver
    jobs = setup_jobs pool
    result.problems = solver.solve(jobs)
    result.transaction = solver.transaction
    result.solver = solver
    result
  end

  def setup_pool
    pool = Solv::Pool.new
    pool.setarch
    @kiwi.repos.each do |uri|
      repo = Repository.new(uri)
      solv = pool.add_repo uri
      solv.add_solv repo.solvable
      pool.addfileprovides
      pool.createwhatprovides
    end
    pool
  end

  def setup_jobs(pool)
    jobs = Array.new
    @kiwi.packages.each do |package|
      item = pool.select(package, Solv::Selection::SELECTION_NAME)
      if item.isempty?
        raise Dice::Errors::SolvJobFailed.new(
          "No solver information for package: #{package}"
        )
      end
      jobs += item.jobs(Solv::Job::SOLVER_INSTALL)
    end
    jobs
  end
end
