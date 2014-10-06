class BuildStatus
  def initialize(details = nil)
    @details = details
  end

  def message
    topic = "Build-System status is: #{self.class}"
    if @details
      message = topic
      message+= ". Last build attempt failed, for details check: #{@details}"
      Logger.info message
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
  end
end
