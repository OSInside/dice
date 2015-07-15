class ConnectionDockerBuildSystem < ConnectionBase
  def ssh
    container_name = recipe.build_name_from_path
    Dice.logger.info(
      "#{self.class}: Attaching to docker container #{container_name}..."
    )
    exec("docker exec -ti #{container_name} bash")
  end
end
