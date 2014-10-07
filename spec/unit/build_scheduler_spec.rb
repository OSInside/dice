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
       job_info = double(File)
       expect(BuildScheduler).to receive(:set_job_name).and_return("xxx")
       expect(Command).to receive(:run).with(
         ["screen", "-S", "xxx", "-L", "-d", "-m",
          "/usr/lib64/ruby/gems/2.0.0/gems/rspec-core-3.1.4/exe/rspec",
          "build", "foo"]
       )
       expect(FileUtils).to receive(:mkdir_p).with("foo/.dice")
       expect(File).to receive(:new).with(
         "foo/.dice/job", "w"
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

