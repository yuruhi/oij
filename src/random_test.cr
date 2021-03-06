require "./command"

module OIJ
  def self.generate_input(generator : Path, option : String?, count : Int32?, oj_args : Array(String)?)
    compile?(generator, option) { |status| OIJ.error("Compile error: #{generator}", status.exit_code) }

    args = ["generate-input", execute_command(generator, option)]
    args << count.to_s if count
    args.concat oj_args if oj_args

    OIJ.info_run("oj", args)
    Process.run("oj", args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    exit $?.exit_code
  end

  def self.generate_output(solver : Path, option : String?, oj_args : Array(String)?)
    compile?(solver, option) { |status| OIJ.error("Compile error: #{solver}", status.exit_code) }

    args = ["generate-output", "-c", execute_command(solver, option)]
    args.concat oj_args if oj_args

    OIJ.info_run("oj", args)
    Process.run("oj", args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    exit $?.exit_code
  end

  def self.hack(hack : Path, hack_option : String?,
                generator : Path, generator_option : String?,
                solver : Path, solver_option : String?,
                oj_args : Array(String)?)
    compile?(hack, hack_option) { |status| OIJ.error("Compile error: #{hack}", status.exit_code) }
    compile?(generator, generator_option) { |status| OIJ.error("Compile error: #{generator}", status.exit_code) }
    compile?(solver, solver_option) { |status| OIJ.error("Compile error: #{solver}", status.exit_code) }

    args = [
      "generate-input",
      "--hack-expected", execute_command(solver, solver_option),
      "--hack", execute_command(hack, hack_option),
      execute_command(generator, generator_option),
    ]
    args.concat oj_args if oj_args

    OIJ.info_run("oj", args)
    Process.run("oj", args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    exit $?.exit_code
  end
end
