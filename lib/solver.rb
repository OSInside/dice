class Solver
  attr_reader :kiwi_config

  def initialize(kiwi_config)
    @kiwi_config = kiwi_config
  end

  def solve
    Dice.logger.info("Solver: Running package solver")
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

  def solver_result(transaction)
    result = []
    transaction.newpackages.each do |solvable|
      package = {}
      details = {}
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
    kiwi_config.repos.each do |uri|
      solv = pool.add_repo uri
      solv.add_solv Repository.solvable(uri)
      pool.addfileprovides
      pool.createwhatprovides
    end
    pool
  end

  def setup_jobs(pool)
    jobs = []
    kiwi_config.packages.each do |package|
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
