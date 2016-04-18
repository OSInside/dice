require_relative "spec_helper"

describe Job do
  before(:each) do
    # test job with an instance of a vagrant build system
    allow_any_instance_of(VagrantBuildSystem).to receive(:host).
      and_return("127.0.0.1")
    allow_any_instance_of(VagrantBuildSystem).to receive(:port).
      and_return("2200")
    allow_any_instance_of(VagrantBuildSystem).to receive(:private_key_path).
      and_return("key")

    # build a recipe to initialize the buildsystem with
    description = "some-description-dir"
    recipe = Recipe.new(description)
    allow(recipe).to receive(:basepath).and_return(description)
    allow(recipe).to receive(:change_working_dir)

    @system = VagrantBuildSystem.new(recipe)

    @job = Job.new(@system)
    @job_name = @job.instance_variable_get(:@job_name)
    @bundle_name = @job.instance_variable_get(:@bundle_name)
  end

  describe "#build" do
    it "raises if build failed" do
      logfile = double(File)
      expect(@job).to receive(:prepare_build)
      expect(File).to receive(:open).with(
        /build\.log/, "w"
      ).and_return(logfile)
      expect(logfile).to receive(:sync=).with(true)
      expect(Command).to receive(:run).with(
        ["ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200", "-i",
        "key", "vagrant@127.0.0.1",
        "sudo kiwi --debug system build --description /vagrant --target-dir /tmp/#{@job_name}"],
        {:stdout=>logfile, :stderr=>logfile}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(logfile).to receive(:close)
      expect(@job).to receive(:cleanup_build)
      expect { @job.build }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#bundle" do
    it "raises if bundle failed" do
      logfile = double(File)
      expect(File).to receive(:open).with(
        /build\.log/, "a"
      ).and_return(logfile)
      expect(logfile).to receive(:sync=).with(true)
      expect(Command).to receive(:run).with(
        ["ssh", "-o", "StrictHostKeyChecking=no", "-p", "2200", "-i",
        "key", "vagrant@127.0.0.1",
        "sudo kiwi result bundle --target-dir /tmp/#{@job_name} --id DiceBuild --bundle-dir /tmp/#{@bundle_name}"],
        {:stdout=>logfile, :stderr=>logfile}
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect(logfile).to receive(:close)
      expect(@job).to receive(:cleanup_build)
      expect { @job.bundle }.to raise_error(Dice::Errors::BuildFailed)
    end
  end

  describe "#get_result" do
    it "raises if result retrieval failed" do
      expect(@job).to receive(:bundle_name).and_return('some_bundle')
      expect(@system).to receive(:archive_job_result).with(
        "/tmp/some_bundle", "some-description-dir/.dice/build_results.tar"
      ).and_raise(
        Dice::Errors::ResultRetrievalFailed.new(nil)
      )
      expect(@job).to receive(:cleanup_build)
      expect { @job.get_result }.to raise_error(
        Dice::Errors::ResultRetrievalFailed
      )
    end
  end
end
