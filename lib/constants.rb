module Dice
  ROOT = File.expand_path("..", File.dirname(__FILE__))
  VAGRANT_BUILD = :VAGRANT
  DOCKER_BUILD = :DOCKER

  DOCKER_BUILD_CONTAINER = "opensuse/dice:latest"

  SSH_USER = "vagrant"
  SSH_PRIVATE_KEY_PATH = File.join(ROOT, "key/vagrant")

  META = ".dice"
  LOCK = "lock"

  VAGRANT_FILE = "Vagrantfile"
  DICE_FILE = "Dicefile"
  KIWI_FILE = "config.xml"

  DIGEST_FILE = "checksum.sha256"
  SCAN_FILE = "scan"
  BUILD_OPTS_FILE = "buildoptions"

  BUILD_LOG = "build.log"
  BUILD_RESULT = "build_results.tar"

  SCREEN_JOB = "job"

  HISTORY = "dice.history"

  module RepoType
    RpmMd = "rpm-md"
    SUSE = "yast2"
    PlainDir = "rpm-dir"
  end
end
