class Solver
  attr_reader :recipe, :kiwi

  def initialize(recipe)
    @recipe = recipe
  end

  def solve
    Dice.logger.info("Solver: Running package solver")
    read_kiwi_config
    pool = setup_pool
    solver = pool.Solver
    jobs = setup_jobs pool

    problems = solver.solve(jobs)
    solver_errors(problems)

    transaction = solver.transaction
    result = solver_result(transaction)
    result
  end

  private

  def read_kiwi_config
    @kiwi = KiwiConfig.new(recipe.basepath)
  end

  def solver_result(transaction)
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

  def solver_errors(problems)
    if !problems.empty?
      info = {
        :problems => { :count => problems.count, :problem => [] },
        :solutions =>{ :solution => [] }
      }
      problem_list = problems.each
      problem_list.each do |p|
        problem = { :id => p.id, :message => p.findproblemrule.info.problemstr }
        info[:problems][:problem] << problem
        solution_list = p.solutions.each
        solution_list.each do |s|
          solution = { :id => s.id, :options => [] }
          solution_options = s.elements(1).each
          solution_options.each do |e|
            solution[:options] << e.str
          end
          info[:solutions][:solution] << solution
        end
      end
      message = JSON.pretty_generate(info)
      raise Dice::Errors::SolvJobFailed.new(
        "Solver problems: #{message}"
      )
    end
  end

  def setup_pool
    pool = Solv::Pool.new
    pool.setarch
    kiwi.repos.each do |uri|
      repo = RepositoryFactory.new(uri)
      solv = pool.add_repo uri
      solv.add_solv repo.solvable
      pool.addfileprovides
      pool.createwhatprovides
    end
    pool
  end

  def setup_jobs(pool)
    jobs = Array.new
    kiwi.packages.each do |package|
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
