class ConnectionVagrantBuildSystem < Connection
  attr_reader :recipe

  def initialize(recipe)
    super(recipe)
    @recipe = recipe
  end

  def ssh
    Logger.info(
      "#{self.class}: ssh into worker for #{recipe.basepath}..."
    )
    exec("vagrant ssh")
  end
end
