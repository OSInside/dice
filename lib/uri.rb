class Uri
  attr_reader :name, :type, :location, :repo_type
  attr_reader :allowed_local_types, :allowed_remote_types
  attr_reader :mount_point

  def initialize(args)
    @name = args[:name]
    @repo_type = args[:repo_type]
    set_uri_type_and_location

    @allowed_remote_types = OpenStruct.new
    allowed_remote_types.http  = true
    allowed_remote_types.https = true
    allowed_remote_types.ftp   = true

    @allowed_local_types  = OpenStruct.new
    allowed_local_types.iso    = true
    allowed_local_types.dir    = true
    allowed_local_types.this   = true

    type_ok?

    set_absolute_location if !is_remote?
  end

  def is_remote?
    remote_location = false
    if allowed_remote_types[type]
      remote_location = true
    end
    remote_location
  end

  def is_iso?
    iso_file = false
    if type == "iso"
      iso_file = true
    end
    iso_file
  end

  def map_loop
    @mount_point ||= mount_loop
  end

  def unmap_loop
    if mount_point
      umount_loop(mount_point)
      @mount_point = nil
    end
  end

  private

  def set_absolute_location
    @location = File.expand_path(@location)
    if !File.exists?(@location)
      raise Dice::Errors::UriNotFound.new(
        "Repository #{location} does not exist"
      )
    end
  end

  def umount_loop(mount_dir)
    begin
      Command.run("sudo", "-n", "umount", mount_dir)
    rescue Cheetah::ExecutionFailed => e
      Dice.logger.error(
        "Umounting #{mount_dir} failed: #{e.stderr}"
      )
    end
    begin
      FileUtils.rmdir(mount_dir)
    rescue
      # ignore if tmpdir remove failed
    end
  end

  def mount_loop
    mount_dir = Dir.mktmpdir
    begin
      Command.run("sudo", "-n", "mount", location, mount_dir)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::MountISOFailed.new(
        "Mounting #{location} failed: #{e.stderr}"
      )
    end
    mount_dir
  end

  def set_uri_type_and_location
    if name =~ /^(.*):\/\/(.*)/
      @type = "#{$1}"
      @location = "#{$2}"
    else
      raise Dice::Errors::UriStyleMatchFailed.new(
        "Can't find resource type/location in #{name}"
      )
    end
  end

  def type_ok?
    if !allowed_local_types[type] && !allowed_remote_types[type]
      raise Dice::Errors::UriTypeUnknown.new(
        "URI style #{name} unknown"
      )
    end
  end
end
