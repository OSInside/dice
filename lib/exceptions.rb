module Dice
  module Errors
    # Superclass for all known errors in Dice.
    class DiceError < StandardError; end

    class BuildFailed < DiceError; end
    class NoDirectory < DiceError; end
    class NoConfigFile < DiceError; end
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
    class NoLogFile < DiceError; end
    class BuildWorkerBusy < DiceError; end
    class CurlFileFailed < DiceError; end
    class SolvToolFailed < DiceError; end
    class SolvJobFailed < DiceError; end
    class UriLoadFileFailed < DiceError; end
    class UriTypeUnknown < DiceError; end
    class NoBuildHistory < DiceError; end
    class RepoTypeUnknown < DiceError; end
    class SemaphoreSemGetFailed < DiceError; end
    class EmptyOptions < DiceError; end
    class ActiveSemaphoreLock < DiceError; end
    class UriStyleMatchFailed < DiceError; end
    class UriTypeUnknown < DiceError; end
    class MountISOFailed < DiceError; end
    class GetSSHPrivateKeyPathFailed < DiceError; end
    class UriNotFound < DiceError; end
    class DockerPullFailed < DiceError; end
  end
end
