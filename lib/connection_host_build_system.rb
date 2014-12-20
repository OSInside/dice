class ConnectionHostBuildSystem < ConnectionBase
  attr_reader :recipe, :ssh_user, :ssh_host, :ssh_private_key

  def initialize(recipe)
    super(recipe)
    @recipe   = recipe
    @ssh_user = Dice.config.ssh_user
    @ssh_host = Dice.config.buildhost
    @ssh_private_key  = Dice.config.ssh_private_key
  end

  def ssh
    Dice.logger.info(
      "#{self.class}: ssh into worker for #{recipe.basepath} with \n\
      url: #{ssh_user}@#{ssh_host} \n\
      key: #{ssh_private_key}"
    )
    exec(
      [
        "ssh", "-o", "StrictHostKeyChecking=no",
        "-o", "NumberOfPasswordPrompts=0",
        "-i", ssh_private_key,
        "#{ssh_user}@#{ssh_host}"
      ].join(" ")
    )
  end
end
