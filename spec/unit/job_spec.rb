require_relative "spec_helper"

describe Job do
  before(:each) do
    expect_any_instance_of(BuildSystem).to receive(:change_working_dir)
    system = VagrantBuildSystem.new("spec/helper/recipe_good")
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
      logfile = double(File)
      expect(@job).to receive(:prepare_build)
      expect(File).to receive(:open).with(
        /build_error.log/, "w"
      ).and_return(logfile)
      expect(Command).to receive(:run).with(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200", "-i",
        /key\/vagrant/, "vagrant@127.0.0.1", "sudo /usr/sbin/kiwi --build /vagrant -d /tmp/image --logfile terminal", {:stdout=>logfile, :stderr=>logfile}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.build }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#bundle" do
    it "raises if bundle failed" do
      logfile = double(File)
      expect(File).to receive(:open).with(
        /build_error.log/, "a+"
      ).and_return(logfile)
      expect(Command).to receive(:run).with(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200", "-i",
        /key\/vagrant/, "vagrant@127.0.0.1", "sudo /usr/sbin/kiwi --bundle-build /tmp/image --bundle-id DiceBuild --destdir /tmp/bundle --logfile terminal",
        {:stdout=>logfile, :stderr=>logfile}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.bundle }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#get_result" do
    it "raises if result retrieval failed" do
      result = double(File)
      expect(File).to receive(:open).and_return(result)
      expect(Command).to receive(:run).
      with("ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200",
        "-i", "/home/ms/Project/dice/key/vagrant",
        "vagrant@127.0.0.1",
        "sudo tar --exclude image-root -C /tmp/bundle -c .",
        {:stdout=>result}).
      and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(result).to receive(:close)
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.get_result }.to raise_error(
        Dice::Errors::ResultRetrievalFailed
      )
    end
  end

  describe "#prepare_build" do
    it "cleans up the buildsystem environment" do
      expect(Command).to receive(:run).
        with("ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200",
          "-i", Dice.config.ssh_private_key,
          "vagrant@127.0.0.1",
          "sudo rm -rf /tmp/image /tmp/bundle"
        ).and_raise(Cheetah::ExecutionFailed.new(nil, nil, nil, nil))
      expect_any_instance_of(BuildSystem).to receive(:halt)
      expect { @job.instance_eval{ prepare_build }}.
        to raise_error(Dice::Errors::PrepareBuildFailed)
    end
  end
end
