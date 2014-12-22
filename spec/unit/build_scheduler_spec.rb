require_relative "spec_helper"

describe BuildScheduler do
   before(:each) do
     allow(Logger).to receive(:info)
     allow(Logger).to receive(:error)
   end

   describe "#self.run_tasks" do
     it "calls run on sorted list of entries in a given directory" do
       dir_list = ["c", "a"]
       expect(Dir).to receive(:glob).with("foo/*").and_return(
         dir_list
       )
       expect(BuildScheduler).to receive(:validate_recipes).with(dir_list)
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("a")
       end
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("c")
       end
       BuildScheduler.run_tasks("foo")
     end
   end
end

