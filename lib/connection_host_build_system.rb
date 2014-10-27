class ConnectionHostBuildSystem < Connection
  def initialize(recipe)
    super(recipe)
    @recipe   = recipe
    @ssh_user = Dice.config.ssh_user
    @ssh_host = Dice.config.buildhost
    @ssh_private_key  = Dice.config.ssh_private_key
  end

  def ssh
    Logger.info(
      "#{self.class}: ssh into worker for #{@recipe.get_basepath} with \n\
      url: #{@ssh_user}@#{@ssh_host} \n\
      key: #{@ssh_private_key}"
    )
    exec("ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -i #{@ssh_private_key} #{@ssh_user}@#{@ssh_host}")
  end
end
