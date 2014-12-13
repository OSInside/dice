require_relative "spec_helper"

describe Logger do
  before :each do
    @message = "foo"
    @basepath = "base"
    @recipe = double(Recipe)
    @logger = Logger.new
    @logger.instance_variable_set(:@recipe, @recipe)
    allow(@recipe).to receive(:basepath).and_return(@basepath)
  end

  describe "#info" do
    it "prints an info message to stdout and updates the logfile" do
      expect(@logger).to receive(:prefix_multiline).with(@message)
      expect(STDOUT).to receive(:puts).with(
        /\[\d+\]\[#{@basepath}\]: #{@message}/
      )
      expect(@logger).to receive(:append_to_logfile)
      @logger.info(@message)
    end
  end

  describe "#command" do
    it "prints an cmd EXEC info message to stdout and updates the logfile" do
      expect(STDOUT).to receive(:puts).with(
        /\[\d+\]\[#{@basepath}\]: EXEC: \[#{@message}\]/
      )
      expect(@logger).to receive(:append_to_logfile)
      @logger.debug = true
      @logger.command(@message)
    end
  end

  describe "#error" do
    it "prints an error message to stderr and updates the logfile" do
      expect(@logger).to receive(:prefix_multiline).with(@message)
      expect(STDERR).to receive(:puts).with(
        /\[\d+\]\[#{@basepath}\]: #{@message}/
      )
      expect(@logger).to receive(:append_to_logfile)
      @logger.error(@message)
    end
  end

  describe "#history" do
    it "raises if history doesn't exists" do
      expect(File).to receive(:exists?).with(
        "#{@basepath}/.dice/dice.history"
      ).and_return(false)
      expect { @logger.history }.to raise_error(
        Dice::Errors::NoBuildHistory, "No history available"
      )
    end
    it "print history on normal operation" do
      expect(File).to receive(:exists?).and_return(true)
      expect(@logger).to receive(:print_history).with(
        "#{@basepath}/.dice/dice.history"
      )
      @logger.history
    end
  end
end
