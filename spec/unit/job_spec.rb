require_relative "spec_helper"

describe Job do
  before(:each) do
    # test job with an instance of a vagrant build system
    allow_any_instance_of(VagrantBuildSystem).to receive(:get_ip).
      and_return("127.0.0.1")
    allow_any_instance_of(VagrantBuildSystem).to receive(:get_port).
      and_return("2200")
    allow_any_instance_of(VagrantBuildSystem).to receive(:halt)
    recipe = Recipe.new("spec/helper/recipe_good")
    expect_any_instance_of(Recipe).to receive(:change_working_dir)
    system = VagrantBuildSystem.new(recipe)
    @job = Job.new(system)
    @basepath = recipe.basepath
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
        /build\.log/, "w"
      ).and_return(logfile)
      expect(Command).to receive(:run).with(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200", "-i",
        /key\/vagrant/, "root@127.0.0.1", "sudo /usr/sbin/kiwi --build /vagrant -d /tmp/image --logfile terminal", {:stdout=>logfile, :stderr=>logfile}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(logfile).to receive(:close)
      expect { @job.build }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#bundle" do
    it "raises if bundle failed" do
      logfile = double(File)
      expect(File).to receive(:open).with(
        /build\.log/, "a"
      ).and_return(logfile)
      expect(Command).to receive(:run).with(
        "ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200", "-i",
        /key\/vagrant/, "root@127.0.0.1", "sudo /usr/sbin/kiwi --bundle-build /tmp/image --bundle-id DiceBuild --destdir /tmp/bundle --logfile terminal",
        {:stdout=>logfile, :stderr=>logfile}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(logfile).to receive(:close)
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
        "root@127.0.0.1",
        "sudo tar --exclude image-root -C /tmp/bundle -c .",
        {:stdout=>result}).
      and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(result).to receive(:close)
      expect { @job.get_result }.to raise_error(
        Dice::Errors::ResultRetrievalFailed
      )
    end
  end
end
