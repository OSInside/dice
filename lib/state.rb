class BuildStatus
  def message
    message = "Build-System status is: #{self.class}"
    message
  end
end

module Dice
  module Status
    class Locked < BuildStatus; end
    class UpToDate < BuildStatus; end
    class BuildRequired < BuildStatus; end
  end
end
