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
    class ResultRetrievalFailed < DiceError; end
    class PrepareBuildFailed < DiceError; end
    class LogFileRetrievalFailed < DiceError; end
    class GetIPFailed < DiceError; end
    class GetPortFailed < DiceError; end
    class SolvePackagesFailed < DiceError; end
    class SolveCreateRecipeResultFailed < DiceError; end
    class SolveCleanUpFailed < DiceError; end
    class HostProvisionFailed < DiceError; end
    class MethodNotImplemented < DiceError; end
  end
end
