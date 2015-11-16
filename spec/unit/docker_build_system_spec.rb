require_relative "spec_helper"

describe DockerBuildSystem do
  before(:each) do
    description = "some/description/dir"
    @recipe = Recipe.new(description)
    allow(@recipe).to receive(:basepath).and_return(description)
    allow(@recipe).to receive(:change_working_dir)

    @system = DockerBuildSystem.new(@recipe)
  end

  describe "#get_lockfile" do
    it "returns the correct lock file for a docker buildsystem" do
      expect(@system.get_lockfile).to eq("some/description/dir/.dice/lock")
    end
  end

  describe "#up" do
    it "raises if up failed" do
      expect(Command).to receive(:run).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect { @system.up }.to raise_error(Dice::Errors::DockerPullFailed)
    end

    it "puts headline and up output on normal operation" do
      expect(Dice::logger).to receive(:info).with(/DockerBuildSystem:/)
      expect(Command).to receive(:run).with(
        "docker", "pull", Dice::DOCKER_BUILD_CONTAINER, {:stdout=>:capture}
      ).and_return("foo")
      expect(Dice::logger).to receive(:info).with("DockerBuildSystem: foo")
      @system.up
    end
  end

  describe "#provision" do
    it "does nothing" do
      expect(@system.provision).to eq(nil)
    end
  end

  describe "#halt" do
    it "resets the working directory if container is already gone" do
      expect(@recipe).to receive(:build_name_from_path).and_return("foo")
      expect(Command).to receive(:run).with(
        "docker", "inspect", "foo"
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, "foo")
      )
      expect(@recipe).to receive(:reset_working_dir)
      @system.halt
    end

    it "print error if container deletion failed" do
      expect(@recipe).to receive(:build_name_from_path).and_return("foo")
      expect(Command).to receive(:run).with("docker", "inspect", "foo")

      expect(Command).to receive(:run).with(
        "docker", "rm", "foo", :stdout => :capture
      ).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, "foo")
      )
      expect(Dice::logger).to receive(:error).with(
        "DockerBuildSystem: Deletion of container failed with: foo"
      )
      @system.halt
    end

    it "resets the working directory and deletes the container" do
      expect(@recipe).to receive(:build_name_from_path).and_return("foo")
      expect(Command).to receive(:run).with("docker", "inspect", "foo")

      expect(Command).to receive(:run).with(
        "docker", "rm", 'foo', :stdout => :capture
      ).and_return("foo")
      expect(Dice::logger).to receive(:info).with("DockerBuildSystem: foo")
      expect(@recipe).to receive(:reset_working_dir)
      @system.halt
    end
  end

  describe "#port" do
    it "does nothing" do
      expect(@system.port).to eq(nil)
    end
  end

  describe "#host" do
    it "does nothing" do
      expect(@system.host).to eq(nil)
    end
  end

  describe "#private_key_path" do
    it "does nothing" do
      expect(@system.private_key_path).to eq(nil)
    end
  end

  describe "#archive_job_result" do
    it "calls the archiving command suitable to this buildsystem" do
      expect(Command).to receive(:run).with([
        "docker", "run", "--rm=true", "--entrypoint=sudo",
        "--privileged=true", "--name=some_description_dir",
        "-v", "some/description/dir:/vagrant",
        "-v", "/tmp:/tmp",
        "schaefi/kiwi-build-box:latest",
        "bash", "-c", "tar -C tmpdir -cf /vagrant/.dice/archive-name ."
      ]).and_raise(
        Cheetah::ExecutionFailed.new(nil, nil, nil, nil)
      )
      expect {
        @system.archive_job_result("tmpdir", "archive-name")
      }.to raise_error(Dice::Errors::ResultRetrievalFailed)
    end
  end

  describe "#job_builder_command" do
    it "builds the commandline to run a command in docker" do
      expect(@system.job_builder_command("command_call")).to eq(
        [
          "docker", "run",
          "--rm=true",
          "--entrypoint=sudo",
          "--privileged=true",
          "--name=some_description_dir",
          "-v", "some/description/dir:/vagrant",
          "-v", "/tmp:/tmp",
          Dice::DOCKER_BUILD_CONTAINER,
          "bash", "-c", "command_call"
        ]
      )
    end
  end

  describe "#is_busy?" do
    it "returns false, never busy" do
      expect(@system.is_busy?).to eq(false)
    end
  end
end
