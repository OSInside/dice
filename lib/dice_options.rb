module Dice
  @@options = nil

  def self.setup_options(options)
    @@options = OpenStruct.new(options) unless @@options
  end

  def self.option
    @@options
  end
end
