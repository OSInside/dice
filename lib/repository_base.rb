class RepositoryBase
  attr_reader :uri, :tmp_dir

  @@kiwi_solv = "/var/tmp/kiwi/satsolver"

  def initialize(uri)
    @uri = uri
  end

  def load_file(source)
    begin
      open(uri + "/" + source, "rb").read
    rescue => e
      raise Dice::Errors::UriLoadFileFailed.new(
        "Downloading file: #{uri}/#{source} failed: #{e}"
      )
    end
  end

  def curl_file(args)
    source = args[:source]
    dest   = args[:dest]
    FileUtils.mkdir_p(File.dirname(dest))
    outfile = File.open(dest, "wb")
    begin
      Command.run("curl", "-L", uri + "/" + source, :stdout => outfile)
    rescue Cheetah::ExecutionFailed => e
      raise Dice::Errors::CurlFileFailed.new(
        "Downloading file: #{uri}/#{source} failed: #{e.stderr}"
      )
    end
    outfile.close
  end

  def create_solv(args)
    tool       = args[:tool]
    source_dir = args[:source_dir]
    dest_dir   = args[:dest_dir]
    FileUtils.mkdir_p(dest_dir)
    rand_name = "solvable-" + (0...8).map { (65 + Kernel.rand(26)).chr }.join
    solvable = File.open(dest_dir + "/" + rand_name, "wb")
    begin
      Command.run(
        "bash", "-c", "gzip -cd --force #{source_dir}/* | #{tool}",
        :stdout => solvable
      )
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
    info.write(uri)
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
    meta.solv = Digest::MD5.hexdigest(uri)
    meta.time = meta.solv + ".timestamp"
    meta.info = meta.solv + ".info"
    meta.uri  = uri
    meta
  end

  def create_tmpdir
    @tmp_dir = Dir.mktmpdir("dice-solver")
    tmp_dir
  end

  def cleanup
    FileUtils.rm_rf @tmp_dir if defined?(tmp_dir)
  end
end

