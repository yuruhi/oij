require "yaml"
require "./file"
require "./utility"

module OIJ
  def self.edit_testcase(name : String, dir : Path, config : YAML::Any) : Nil
    Dir.mkdir(dir) unless Dir.exists?(dir)
    editor = config["editor"]? || ENV["EDITOR"] || error("Not found editor")
    input, output = normalize_testcase_files(name, dir, config)
    File.touch(input)
    File.touch(output)
    info("Make testcase files: #{input} #{output}")
    system "#{editor} #{input} #{output}"
  end

  def self.print_testcase(name : String, dir : Path, config : YAML::Any) : Nil
    input, output = normalize_testcase_files(name, dir, config)
    print_file({input, output}, config)
  end
end
