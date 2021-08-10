require "yaml"
require "./utility"

module OIJ
  def self.normalize_input_file(file : String, config : YAML::Any) : Path
    config["input_file_mapping"]?.try &.as_a.each do |(pattern, replacement)|
      file = file.sub(Regex.new(pattern.as_s), replacement.as_s)
    end
    unless File.exists?(file)
      error("Not found input file: #{file}")
    end
    Path[file]
  end

  def self.normalize_testcase_files(name : String, dir : Path, config : YAML::Any) : {Path, Path}
    config["testcase_mapping"]?.try &.as_a.each do |(pattern, replacement)|
      name = name.sub(Regex.new(pattern.as_s), replacement.as_s)
    end
    {dir / "#{name}.in", dir / "#{name}.out"}
  end

  def self.print_file(file : Path, config : YAML::Any) : Nil
    error("Not found testcase file: #{file}") unless File.exists?(file)
    if printer = config["printer"]?
      system "#{printer} #{file}"
    else
      info("#{file} (#{File.size(file)} byte):")
      puts File.read(file), ""
    end
  end

  def self.print_file(files : Enumerable(Path), config : YAML::Any) : Nil
    files.each do |file|
      error("Not found testcase file: #{file}") unless File.exists?(file)
    end
    if printer = config["printer"]?
      system "#{printer} #{files.join(' ')}"
    else
      files.each do |file|
        info("#{file} (#{File.size(file)} byte):")
        puts File.read(file), ""
      end
    end
  end
end
