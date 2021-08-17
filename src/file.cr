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
      OIJ.info_run(printer, [file])
      Process.run(printer, [file], shell: true, input: Process::Redirect::Inherit, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
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
      OIJ.info_run(printer, files.map(&.to_s), true)
      Process.run(printer, files.map(&.to_s), shell: true, input: Process::Redirect::Inherit, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    else
      files.each do |file|
        OIJ.info("#{file} (#{File.size(file)} byte):")
        puts File.read(file), ""
      end
    end
  end

  def self.bundled_file(file : Path) : File
    if command = OIJ::Config.bundler?(file.extension[1..]).try &.replace_variables(file)
      File.tempfile("bundled", file.extension) do |tmp|
        OIJ.info_run(command)
        Process.run(command, shell: true, input: Process::Redirect::Inherit, output: tmp, error: Process::Redirect::Inherit)
        OIJ.error("Failed to bundle: #{file}") unless $?.success?
      end
    else
      File.new(file)
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
