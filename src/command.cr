require "yaml"
require "./utility"

module OIJ
  def self.execute_command(file : Path, input_file : Path?) : String
    extension = file.extension[1..]
    command = OIJ::Config.execute(extension) {
      OIJ.error("Not found execute command: .#{extension}")
    }.gsub("${file}", file)
    if input_file
      OIJ.error("Not found input file: #{input_file}") unless File.exists?(input_file)
      "#{command} < #{input_file}"
    else
      command
    end
  end

  def self.compile_command?(file : Path, option : String?) : String?
    extension = file.extension[1..]
    OIJ::Config.compile?(extension, option).try &.gsub("${file}", file)
  end

  def self.compile_command(file : Path, option : String?) : String
    compile_command?(file, option) ||
      OIJ.error "Not found compile command: #{file.extension}" +
                (option.nil? ? "" : " (option: #{option})")
  end

  def self.compile?(file : Path, option : String?) : Bool
    command = compile_command?(file, option) || return true
    system command
  end

  def self.compile(file : Path, option : String?) : Bool
    system compile_command(file, option)
  end

  def self.execute(file : Path, input_file : String?)
    input_file = normalize_input_file(input_file) if input_file
    system execute_command(file, input_file)
  end

  def self.run(file : Path, input_file : String?, option : String?)
    compile?(file, option) || OIJ.error("Compile error")
    execute(file, input_file)
  end

  def self.test(file : Path)
    system "oj test -c '#{execute_command(file, nil)}'"
  end

  def self.compile_and_test(file : Path, option : String?)
    compile?(file, option) || OIJ.error("Compile error")
    system "oj test -c '#{execute_command(file, nil)}'"
  end
end
