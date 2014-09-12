module Dice
  ROOT = File.expand_path("..", File.dirname(__FILE__))
  # default ssh private key is the vagrant key
  SSH_PRIVATE_KEY = File.join(ROOT, "key/vagrant")
  # default ssh job user is vagrant
  DEFAULT_USER = "vagrant"
end
