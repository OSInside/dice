module Dice
  ROOT = File.expand_path("..", File.dirname(__FILE__))
  VAGRANT_BUILD = "__VAGRANT__"

  META = ".dice"
  LOCK = "lock"

  VAGRANT_FILE = "Vagrantfile"
  DICE_FILE = "Dicefile"
  KIWI_FILE = "config.xml"

  DIGEST_FILE = "checksum.sha256"
  SCAN_FILE = "scan"

  BUILD_ERROR_LOG = "build_error.log"
  BUILD_RESULT = "build_results.tar"

  SCREEN_JOB = "job"
end
