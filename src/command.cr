require "yaml"
require "./utility"
require "./file"

module OIJ
  def self.execute_command(file : Path, input_file : Path? = nil) : String
    extension = file.extension[1..]
    command = OIJ::Config.execute(extension) {
      OIJ.error("Not found execute command: .#{extension}")
    }.replace_variables(file)
    if input_file
      OIJ.error("Not found input file: #{input_file}") unless File.exists?(input_file)
      "#{command} < #{input_file}"
    else
      command
    end
  end

  def self.compile_command?(file : Path, option : String?) : String?
    extension = file.extension[1..]
    OIJ::Config.compile?(extension, option).try &.replace_variables(file)
  end

  def self.compile_command(file : Path, option : String?) : String
    compile_command?(file, option) ||
      OIJ.error "Not found compile command: #{file.extension}" +
                (option.nil? ? "" : " (option: #{option})")
  end

  def self.compile?(file : Path, option : String?) : Bool
    command = compile_command?(file, option) || return true
    OIJ.info_run command
    system command
  end

  def self.compile(file : Path, option : String?) : Bool
    command = compile_command(file, option)
    OIJ.info_run command
    system command
  end

  def self.execute(file : Path, input_file : String?)
    input_file = normalize_input_file(input_file) if input_file
    command = execute_command(file, input_file)
    OIJ.info_run command
    system command
  end

  def self.run(file : Path, input_file : String?, option : String?)
    compile?(file, option) || OIJ.error("Compile error")
    execute(file, input_file)
  end

  def self.test(file : Path, oj_args : Array(String)?)
    args = ["test", "-c", execute_command(file)]
    args.concat oj_args if oj_args
    OIJ.info_run "oj", args
    Process.run("oj", args: args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
  end

  def self.compile_and_test(file : Path, option : String?, oj_args : Array(String)?)
    compile?(file, option) || OIJ.error("Compile error")
    OIJ.test(file, oj_args)
  end
end
