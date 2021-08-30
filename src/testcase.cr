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

    args = {input.to_s, output.to_s}
    OIJ.info_run(editor, args, true)
    Process.run(editor, args, shell: true, input: Process::Redirect::Inherit, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    exit $?.exit_code
  end

  def self.print_testcase(name : String, dir : Path) : Nil
    input, output = normalize_testcase_files(name, dir)
    print_file({input, output})
  end
end
