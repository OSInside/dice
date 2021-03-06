require_relative "spec_helper"

describe BuildScheduler do
   before(:each) do
     allow(Logger).to receive(:info)
     allow(Logger).to receive(:error)
   end

   describe "#self.run_tasks" do
     it "calls run on each element of given description dir list" do
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("a")
       end
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("c")
       end
       BuildScheduler.run_tasks(["a", "c"])
     end
   end

   describe "#self.description_list" do
     it "returns sorted list of sub directories below given base directory" do
       dir_list = ["c", "a"]
       expect(Dir).to receive(:glob).with("foo/*").and_return(
         dir_list
       )
       expect(BuildScheduler.description_list("foo")).to eq(["a", "c"])
     end
   end
end

