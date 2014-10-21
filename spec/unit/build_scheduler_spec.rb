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
       recipe = double(Recipe)
       expect(recipe).to receive(:get_basepath).and_return("a")
       allow(Recipe).to receive(:new).and_return(recipe)
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("a")
       end
       expect(recipe).to receive(:get_basepath).and_return("b")
       allow(Recipe).to receive(:new).and_return(recipe)
       expect(BuildScheduler).to receive(:fork).and_yield do |block|
         expect(block).to receive(:run).with("b")
       end
       BuildScheduler.run_tasks("foo")
     end
   end

   describe "#self.run" do
     it "calls dice build" do
       job_info = double(File)
       expect(BuildScheduler).to receive(:set_job_name).and_return("xxx")
       expect(Command).to receive(:run).with(
         ["screen", "-S", "xxx", "-d", "-m", /rspec/, "build", "foo"]
       )
       expect(FileUtils).to receive(:mkdir_p).with("foo/.dice")
       expect(File).to receive(:new).with(
         "foo/.dice/job", "a+"
       ).and_return(job_info)
       expect(job_info).to receive(:puts).with("xxx")
       expect(job_info).to receive(:close)
       BuildScheduler.run("foo")
     end
   end

   describe "#self.set_job_name" do
     it "builds a name for a screen job" do
       (0...8).map {
         expect(Kernel).to receive(:rand).and_return(10)
       }
       expect(BuildScheduler.set_job_name).to eq("dice-KKKKKKKK")
     end
   end
end

