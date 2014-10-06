require_relative "spec_helper"

describe BuildScheduler do
   before(:each) do
     allow(Logger).to receive(:info)
     allow(Logger).to receive(:error)
   end

   describe "#self.run_tasks" do
     it "calls run on sorted list of entries in a given directory" do
       dir_list = ["a", "c", "b"]
       expect(Dir).to receive(:glob).with("foo/*").and_return(
         dir_list
       )
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("a")
       end
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("b")
       end
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("c")
       end
       BuildScheduler.run_tasks("foo")
     end
   end

   describe "#self.run" do
     it "calls dice build" do
       expect(BuildScheduler).to receive(:system).with(/build foo/)
       BuildScheduler.run("foo")
     end
   end
end

