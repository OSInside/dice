class ConnectionVagrantBuildSystem < ConnectionBase
  def ssh
    Dice.logger.info(
      "#{self.class}: ssh into worker for #{recipe.basepath}..."
    )
    exec("vagrant ssh")
  end
end
