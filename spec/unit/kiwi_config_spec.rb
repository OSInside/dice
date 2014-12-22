require_relative "spec_helper"

describe KiwiConfig do
  before(:each) do
    @kiwi_config = KiwiConfig.new("spec/helper")
  end

  describe "#initialize" do
    it "reads in a kiwi XML document" do
      file = double(File)
      expect(File).to receive(:open).with("foo/config.xml").and_return(file)
      expect(REXML::Document).to receive(:new).with(file)
      expect(file).to receive(:close)
      KiwiConfig.new("foo")
    end
  end

  describe "#repos" do
    it "reads repository/source from XML tree" do
      result = ["http://bob"]
      expect(@kiwi_config.repos).to eq(result)
    end
  end

  describe "packages" do
    it "reads packages/package|namedCollection from XML tree" do
      result = ["a", "b", "c", "pattern:x"]
      expect(@kiwi_config.packages).to eq(result)
    end
  end

  describe "solve_packages" do
    it "calls solver operation over packages" do
      package_solver = double(Solver)
      expect(Solver).to receive(:new).and_return(package_solver)
      expect(package_solver).to receive(:solve)
      @kiwi_config.solve_packages
    end
  end
end
