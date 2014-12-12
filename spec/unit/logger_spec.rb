require_relative "spec_helper"

describe Logger do
  before :each do
    @logger = Logger.new
    @message = "foo"
  end

  describe "#info" do
    it "prints an info message to stdout and updates the logfile" do
      expect(@logger).to receive(:prefix_multiline).with(@message)
      expect(STDOUT).to receive(:puts).with(/\[\d+\]: #{@message}/)
      expect(@logger).to receive(:append_to_logfile)
      @logger.info(@message)
    end
  end

  describe "#command" do
    it "prints an cmd EXEC info message to stdout and updates the logfile" do
      expect(STDOUT).to receive(:puts).with(/\[\d+\]: EXEC: \[#{@message}\]/)
      expect(@logger).to receive(:append_to_logfile)
      @logger.debug = true
      @logger.command(@message)
    end
  end

  describe "#error" do
    it "prints an error message to stderr and updates the logfile" do
      expect(@logger).to receive(:prefix_multiline).with(@message)
      expect(STDERR).to receive(:puts).with(/\[\d+\]: #{@message}/)
      expect(@logger).to receive(:append_to_logfile)
      @logger.error(@message)
    end
  end
end
