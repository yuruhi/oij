require "yaml"
require "./utility"

module OIJ
  def self.execute_command(file : Path, input_file : Path?) : String
    extension = file.extension[1..]
    if command = OIJ::Config.get.dig?("execute", extension)
      command = command.as_s.gsub("${file}", file)
      if input_file
        error("Not found input file: #{input_file}") unless File.exists?(input_file)
        "#{command} < #{input_file}"
      else
        command
      end
    else
      error("Not found execute command: .#{extension}")
    end
  end

  def self.compile_command?(file : Path) : String?
    extension = file.extension[1..]
    if command = OIJ::Config.get.dig?("compile", extension)
      command.as_s.gsub("${file}", file)
    end
  end

  def self.compile?(file : Path) : Bool
    command = compile_command?(file) || return true
    system command
  end

  def self.compile(file : Path) : Bool
    command = compile_command?(file) ||
              error("Not found compile command: #{file.extension}")
    system command
  end

  def self.execute(file : Path, input_file : String?)
    input_file = normalize_input_file(input_file) if input_file
    system execute_command(file, input_file)
  end

  def self.run(file : Path, input_file : String?)
    compile?(file) || error("Compile error")
    execute(file, input_file)
  end

  def self.test(file : Path)
    system "oj test -c '#{execute_command(file, nil)}'"
  end

  def self.compile_and_test(file : Path)
    compile?(file) || error("Compile error")
    system "oj test -c '#{execute_command(file, nil)}'"
  end
end
