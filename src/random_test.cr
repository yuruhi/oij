require "./command"

module OIJ
  def self.generate_input(generator : Path, option : String?, count : Int32?, oj_args : Array(String)?)
    compile?(generator, option)

    args = ["generate-input", execute_command(generator)]
    args << count.to_s if count
    args.concat oj_args if oj_args

    OIJ.info_run("oj", args)
    Process.run("oj", args: args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
  end

  def self.generate_output(solver : Path, option : String?, oj_args : Array(String)?)
    compile?(solver, option)

    args = ["generate-output", "-c", execute_command(solver)]
    args.concat oj_args if oj_args

    OIJ.info_run("oj", args)
    Process.run("oj", args: args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
  end

  def self.hack(hack : Path, hack_option : String?,
                generator : Path, generator_option : String?,
                solver : Path, solver_option : String?,
                oj_args : Array(String)?)
    compile?(hack, hack_option) || OIJ.error("Compile error: #{hack}")
    compile?(generator, generator_option) || OIJ.error("Compile error: #{generator}")
    compile?(solver, solver_option) || OIJ.error("Compile error: #{solver}")

    args = [
      "generate-input",
      "--hack-expected", execute_command(solver),
      "--hack", execute_command(hack),
      execute_command(generator),
    ]
    args.concat oj_args if oj_args

    OIJ.info_run("oj", args)
    Process.run("oj", args: args, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
  end
end
