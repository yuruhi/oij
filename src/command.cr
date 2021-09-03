require "yaml"
require "./utility"
require "./file"

module OIJ
  def self.compile_command?(file : Path, option : String?) : String?
    extension = file.extension[1..]
    OIJ::Config.compile?(extension, option).try &.replace_variables(file)
  end

  def self.compile_command(file : Path, option : String?) : String
    compile_command?(file, option) ||
      OIJ.error "Not found compile command: #{file.extension}" + (option.nil? ? "" : " (option: #{option})")
  end

  def self.execute_command(file : Path, option : String?) : String
    extension = file.extension[1..]
    OIJ::Config.execute(extension, option) {
      OIJ.error "Not found execute command: #{file.extension}" +
                (option.nil? ? "" : " (option: #{option})")
    }.replace_variables(file)
  end

  def self.compile?(file : Path, option : String?, &error) : Bool
    command = compile_command?(file, option) || return true
    OIJ.info_run command
    system(command) || yield($?)
  end

  def self.compile?(file : Path, option : String?) : Bool
    compile?(file, option) do |status|
      OIJ.error("Compile error", status.exit_code)
    end
  end

  def self.compile(file : Path, option : String?, &error) : Bool
    command = compile_command(file, option)
    OIJ.info_run command
    system(command) || yield $?
  end

  def self.compile(file : Path, option : String?) : Bool
    compile(file, option) do |status|
      OIJ.error("Compile error", status.exit_code)
    end
  end

  def self.execute(file : Path, option : String?, input : String?, &error)
    input_file = input.try { |s| normalize_input_file(s) }
    command = execute_command(file, option)
    OIJ.info_run command, message: input_file ? "input file: #{input_file}" : ""
    input_stdio = input_file ? File.new(input_file) : Process::Redirect::Inherit
    Process.run command, shell: true, input: input_stdio, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit
    yield $?
  end

  def self.execute(file : Path, option : String?, input : String?) : NoReturn
    execute(file, option, input) { |status| exit status.exit_code }
  end

  def self.run(file : Path, option : String?, input_file : String?) : NoReturn
    compile?(file, option)
    execute(file, option, input_file)
  end

  def self.test(file : Path, option : String?, oj_args : Array(String)?) : NoReturn
    args = ["test", "-c", execute_command(file, option)]
    args.concat oj_args if oj_args
    OIJ.info_run "oj", args
    Process.run("oj", args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    exit $?.exit_code
  end

  def self.compile_and_test(file : Path, option : String?, oj_args : Array(String)?)
    compile?(file, option)
    OIJ.test(file, option, oj_args)
  end
end
