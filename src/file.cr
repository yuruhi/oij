require "yaml"
require "./utility"

module OIJ
  def self.normalize_input_file(file : String) : Path
    OIJ::Config.input_file_mapping.each do |pattern, replacement|
      file = file.sub(Regex.new(pattern), replacement)
    end
    unless File.exists?(file)
      error("Not found input file: #{file}")
    end
    Path[file]
  end

  def self.normalize_testcase_files(name : String, dir : Path) : {Path, Path}
    OIJ::Config.testcase_mapping.each do |pattern, replacement|
      name = name.sub(Regex.new(pattern), replacement)
    end
    {dir / "#{name}.in", dir / "#{name}.out"}
  end

  def self.print_file(file : Path) : Nil
    error("Not found testcase file: #{file}") unless File.exists?(file)
    if printer = OIJ::Config.printer?
      system "#{printer} #{file}"
    else
      info("#{file} (#{File.size(file)} byte):")
      puts File.read(file), ""
    end
  end

  def self.print_file(files : Enumerable(Path)) : Nil
    files.each do |file|
      error("Not found testcase file: #{file}") unless File.exists?(file)
    end
    if printer = OIJ::Config.printer?
      system "#{printer} #{files.join(' ')}"
    else
      files.each do |file|
        info("#{file} (#{File.size(file)} byte):")
        puts File.read(file), ""
      end
    end
  end

  def self.bundled_file(file : Path) : File
    bundler = OIJ::Config.bundler(file.extension[1..]) {
      error("Not found bundler for #{file.extension}")
    }
    File.tempfile("bundled", file.extension) do |tmp|
      command = "#{bundler} #{file}"
      info("$ #{command}")
      bundled = `#{command}`
      if $?.success?
        tmp.print bundled
      else
        error("Failed to bundle: #{command}")
      end
    end
  end
end
