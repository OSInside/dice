class ConnectionVagrantBuildSystem < Connection
  def initialize(recipe)
    super(recipe)
    @recipe = recipe
  end

  def ssh
    Logger.info(
      "#{self.class}: ssh into worker for #{@recipe.get_basepath}..."
    )
    exec("vagrant ssh")
  end
end
