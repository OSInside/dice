class ConnectionHostBuildSystem < ConnectionBase
  def ssh
    ssh_pkey = Dice.config.ssh_private_key
    ssh_user = Dice.config.ssh_user
    ssh_host = Dice.config.buildhost
    Dice.logger.info(
      "#{self.class}: ssh into worker for #{recipe.basepath} with \n\
      url: #{ssh_user}@#{ssh_host} \n\
      key: #{ssh_pkey}"
    )
    exec(
      [
        "ssh", "-o", "StrictHostKeyChecking=no",
        "-o", "NumberOfPasswordPrompts=0",
        "-i", ssh_pkey,
        "#{ssh_user}@#{ssh_host}"
      ].join(" ")
    )
  end
end
