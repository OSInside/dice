class RepositoryBase
  attr_reader :uri, :tmp_dir

  @@kiwi_solv = "/var/tmp/kiwi/satsolver"

  def initialize(uri)
    @uri = uri
  end

  def load_file(source)
    data = nil
    location = uri.location
    if uri.is_iso?
      location = uri.map_loop
    elsif uri.is_remote?
      # uses ruby's openuri implementation to handle mime types
      # Thus loading small amount of data from a network location
      # can also be done with load_file instead of curl_file and
      # directly reads the data into a variable instead of creating
      # an output file like curl_file does
      location = uri.name
    end
    begin
      handle = open(location + "/" + source, "rb")
      data = handle.read
      handle.close
    rescue => e
      raise Dice::Errors::UriLoadFileFailed.new(
        "Downloading file: #{location}/#{source} failed: #{e}"
      )
    end
    if uri.is_iso?
      uri.unmap_loop
    end
    data
  end

  def curl_file(args)
    source = args[:source]
    dest   = args[:dest]
    FileUtils.mkdir_p(File.dirname(dest))
    outfile = File.open(dest, "wb")
    location = uri.name
    if uri.is_iso?
      location = "file://" + uri.map_loop
    elsif !uri.is_remote?
      location = "file://" + uri.location
    end
    begin
      Command.run("curl", "-L", location + "/" + source, :stdout => outfile)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::CurlFileFailed.new(
        "Downloading file: #{location}/#{source} failed: #{e.stderr}"
      )
    end
    outfile.close
    if uri.is_iso?
      uri.unmap_loop
    end
    check_404_header(source, dest) if uri.is_remote?
  end

  def create_solv(args)
    tool       = args[:tool]
    source_dir = args[:source_dir]
    dest_dir   = args[:dest_dir]
    FileUtils.mkdir_p(dest_dir)
    rand_name = "solvable-" + (0...8).map { (65 + Kernel.rand(26)).chr }.join
    solvable = File.open(dest_dir + "/" + rand_name, "wb")
    begin
      if tool == 'rpms2solv'
        Command.run(
          "bash", "-c", "#{tool} #{source_dir}/*.rpm",
          :stdout => solvable
        )
      else
        Command.run(
          "bash", "-c", "gzip -cd --force #{source_dir}/* | #{tool}",
          :stdout => solvable
        )
      end
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::SolvToolFailed.new(
        "Creating solvable failed: #{e.stderr}"
      )
    end
    solvable.close
    rand_name
  end

  def merge_solv(source_dir, timestamp = "static")
    meta = solv_meta
    FileUtils.mkdir_p(@@kiwi_solv) if !File.exists?(@@kiwi_solv)
    solvable = File.open(@@kiwi_solv + "/" + meta.solv, "wb")
    begin
      Command.run(
        "bash", "-c", "mergesolv #{source_dir}/*",
        :stdout => solvable
      )
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::SolvToolFailed.new(
        "Creating solvable failed: #{e.stderr}"
      )
    end
    solvable.close
    time = File.open(@@kiwi_solv + "/" + meta.time, "wb")
    time.write(timestamp)
    time.close
    info = File.open(@@kiwi_solv + "/" + meta.info, "wb")
    info.write(uri.name)
    info.close
    meta.solv
  end

  def uptodate?(timestamp = "static")
    result = true
    meta = solv_meta
    time_file = @@kiwi_solv + "/" + meta.time
    cur_time = ""
    cur_time = File.read(time_file) if File.exists?(time_file)
    if (cur_time != timestamp)
      result = false
    end
    result
  end

  def solv_meta
    meta = OpenStruct.new
    meta.solv = Digest::MD5.hexdigest(uri.name)
    meta.time = meta.solv + ".timestamp"
    meta.info = meta.solv + ".info"
    meta.uri  = uri.name
    meta
  end

  def create_tmpdir
    @tmp_dir = Dir.mktmpdir("dice-solver")
    tmp_dir
  end

  def cleanup
    FileUtils.rm_rf tmp_dir if tmp_dir
  end

  private

  def check_404_header(source, dest)
    outfile = File.open(dest, "rb")
    # if there is a 404 not found information it will be in the first two lines
    header = outfile.readline
    header+= outfile.readline
    outfile.close
    if header =~ /404 Not Found/
      raise Dice::Errors::CurlFileFailed.new(
        "Downloading file: #{uri.name}/#{source} failed: 404 not found"
      )
    end
  end
end

