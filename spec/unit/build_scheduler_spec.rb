require_relative "spec_helper"

describe BuildScheduler do
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
     it "calls BuildTask run and returns false on raise" do
       task = double(BuildTask)
       expect(BuildTask).to receive(:new).with("foo").and_return(task)
       expect(task).to receive(:run).and_raise(
         Dice::Errors::HostProvisionFailed.new("foo")
       )
       expect(BuildScheduler.run("foo")).to eq(false)
     end
   end
end

