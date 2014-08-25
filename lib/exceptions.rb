module Dice
  module Errors
    # Superclass for all known errors in Dice.
    class DiceError < StandardError; end

    class BuildFailed < DiceError; end
    class NoDirectory < DiceError; end
    class NoVagrantFile < DiceError; end
    class NoKIWIConfig < DiceError; end
    class VagrantUpFailed < DiceError; end
    class VagrantHaltFailed < DiceError; end
    class VagrantProvisionFailed < DiceError; end
    class BundleBuildFailed < DiceError; end
  end
end
