require_relative "spec_helper"

describe Job do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    expect_any_instance_of(BuildSystem).to receive(:get_ip)
    system = BuildSystem.new("spec/helper/recipe_good")
    system.instance_variable_set(
      :@up_output, "[jeos_sle12_build] -- 22 => 2200 (adapter 1)"
    )
    @job = Job.new(system)
    @basepath = system.get_basepath
  end

  describe "#initialize" do
    it "raises if job gets no BuildSystem" do
      expect { Job.new(File) }.to raise_error
    end
  end

  describe "#build" do
    it "raises if build failed" do
      expect(@job).to receive(:prepare_build)
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(@job).to receive(:get_buildlog)
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.build }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#get_result" do
    it "raises if result retrieval failed" do
      expect(File).to receive(:open)
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.get_result }.to raise_error(
        Dice::Errors::ResultRetrievalFailed
      )
    end
  end

  describe "#prepare_build" do
    it "cleans up the buildsystem environment" do
      expect(Command).to receive(:run).
        with("ssh", "-p", "2200", "-i", Dice::SSH_PRIVATE_KEY,
          "vagrant@", "sudo rm -rf /image; sudo touch /buildlog"
        ).and_raise(Cheetah::ExecutionFailed.new(nil, nil, nil, nil))
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.instance_eval{ prepare_build }}.
        to raise_error(Dice::Errors::PrepareBuildFailed)
    end
  end

  describe "#get_buildlog" do
    it "retrieves the buildlog form the buildsystem" do
      expect(File).to receive(:open).with(@basepath + "/buildlog", "w")
      expect(Command).to receive(:run).
        with("ssh", "-p", "2200", "-i", Dice::SSH_PRIVATE_KEY,
          "vagrant@", "sudo cat /buildlog", :stdout=>nil
        ).and_raise(Cheetah::ExecutionFailed.new(nil, nil, nil, nil))
      expect(FileUtils).to receive(:rm)
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.instance_eval{ get_buildlog }}.
        to raise_error(Dice::Errors::LogFileRetrievalFailed)
    end
  end
end
