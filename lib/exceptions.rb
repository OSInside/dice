module Dice
  module Errors
    # Superclass for all known errors in Dice.
    class DiceError < StandardError; end

    class BuildFailed < DiceError; end
  end
end
