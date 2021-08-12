require "yaml"
require "./file"
require "./utility"

module OIJ
  def self.edit_testcase(name : String, dir : Path) : Nil
    unless Dir.exists?(dir)
      Dir.mkdir(dir)
      OIJ.info("Make directory: #{dir}")
    end
    editor = OIJ::Config.editor? || ENV["EDITOR"] || error("Not found editor")
    input, output = normalize_testcase_files(name, dir)
    File.touch(input)
    File.touch(output)
    OIJ.info("Make testcase files: #{input} #{output}")
    system "#{editor} #{input} #{output}"
  end

  def self.print_testcase(name : String, dir : Path) : Nil
    input, output = normalize_testcase_files(name, dir)
    print_file({input, output})
  end
end
