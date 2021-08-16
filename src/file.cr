require "yaml"
require "./utility"
require "./config"

module OIJ
  def self.normalize_input_file(file : String) : Path
    OIJ::Config.input_file_mapping?.try &.each do |pattern, replacement|
      file = file.sub(Regex.new(pattern), replacement)
    end
    unless File.exists?(file)
      OIJ.error("Not found input file: #{file}")
    end
    Path[file]
  end

  def self.normalize_testcase_files(name : String, dir : Path) : {Path, Path}
    OIJ::Config.testcase_mapping?.try &.each do |pattern, replacement|
      name = name.sub(Regex.new(pattern), replacement)
    end
    {dir / "#{name}.in", dir / "#{name}.out"}
  end

  def self.print_file(file : Path) : Nil
    OIJ.error("Not found testcase file: #{file}") unless File.exists?(file)
    if printer = OIJ::Config.printer?
      system "#{printer} #{file}"
    else
      OIJ.info("#{file} (#{File.size(file)} byte):")
      puts File.read(file), ""
    end
  end

  def self.print_file(files : Enumerable(Path)) : Nil
    files.each do |file|
      OIJ.error("Not found testcase file: #{file}") unless File.exists?(file)
    end
    if printer = OIJ::Config.printer?
      system "#{printer} #{files.join(' ')}"
    else
      files.each do |file|
        OIJ.info("#{file} (#{File.size(file)} byte):")
        puts File.read(file), ""
      end
    end
  end

  def self.bundled_file(file : Path) : File
    bundler = OIJ::Config.bundler?(file.extension[1..]).try &.replace_variables(file)
    if bundler.nil?
      return File.new(file)
    end
    File.tempfile("bundled", file.extension) do |tmp|
      command = "#{bundler} #{file}"
      OIJ.info("$ #{command}")
      bundled = `#{command}`
      if $?.success?
        tmp.print bundled
      else
        OIJ.error("Failed to bundle: #{command}")
      end
    end
  end
end

class String
  def replace_variables(file : Path)
    gsub(/\$\{(.*?)\}/) do |var|
      case $1
      when "file"                  then file
      when "basename"              then file.basename
      when "dirname"               then file.dirname
      when "extension"             then file.extension
      when "basename_no_extension" then file.basename(file.extension)
      when "relative_file"         then file.expand
      when "relative_dirname"      then file.expand.dirname
      else                              var
      end
    end
  end
end
