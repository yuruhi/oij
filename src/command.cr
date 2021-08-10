require "yaml"
require "./utility"
require "./url"

module OIJ
  def self.execute_command(file : Path, input_file : Path?, config : YAML::Any) : String
    extension = file.extension[1..]
    if command = config["execute"]?.try &.[extension]?.try &.as_s
      command = command.gsub("${file}", file)
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

  def self.compile_command?(file : Path, config : YAML::Any) : String?
    extension = file.extension[1..]
    if command = config["compile"]?.try &.[extension]?.try &.as_s
      command.gsub("${file}", file)
    end
  end

  def self.compile?(file : Path, config : YAML::Any) : Bool
    command = compile_command?(file, config) || return true
    system command
  end

  def self.compile(file : Path, config : YAML::Any) : Bool
    command = compile_command?(file, config) ||
              error("Not found compile command: #{file.extension}")
    system command
  end

  def self.execute(file : Path, input_file : String?, config : YAML::Any)
    input_file = normalize_input_file(input_file, config) if input_file
    system execute_command(file, input_file, config)
  end

  def self.run(file : Path, input_file : String?, config : YAML::Any)
    compile?(file, config) || error("Compile error")
    execute(file, input_file, config)
  end

  def self.test(file : Path, config : YAML::Any)
    system "oj test -c '#{execute_command(file, nil, config)}'"
  end

  def self.compile_and_test(file : Path, config : YAML::Any)
    compile?(file, config) || error("Compile error")
    system "oj test -c '#{execute_command(file, nil, config)}'"
  end

  def self.download(directory : Path, config : YAML::Any) : Nil
    system "oj d #{get_url(directory, config)}"
  end

  def self.submit(file : Path, directory : Path, config : YAML::Any) : Nil
    system "oj s #{get_url(directory, config)} #{file}"
  end

  def self.bundle(file : Path, config : YAML::Any) : Nil
    bundler = config["bundler"]?.try(&.[file.extension[1..]]?) || error("Not found bundler for #{file.extension}")
    system "#{bundler} #{file}"
  end
end
