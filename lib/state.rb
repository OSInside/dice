class BuildStatus
  def initialize(details = nil)
    @details = details
  end

  def message
    topic = "Build-System status is: #{self.class}"
    case self
    when Dice::Status::BuildErrorExists
      message = topic + ". For details see #{@details}"
      Logger.info(message)
    else
      Logger.info topic
    end
  end
end

module Dice
  module Status
    class Unknown < BuildStatus; end
    class BuildRunning < BuildStatus; end
    class UpToDate < BuildStatus; end
    class BuildRequired < BuildStatus; end
    class BuildErrorExists < BuildStatus; end
  end
end
