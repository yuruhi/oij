require "./command"

module OIJ
  def self.generate_input(generator : Path, option : String?, count : Int32?, args : Array(String)?)
    compile?(generator, option)
    system "oj g/i '#{execute_command(generator, nil)}' #{count ? "#{count} " : ""}#{args ? %["${@}" ] : ""}", args
  end

  def self.generate_output(solver : Path, option : String?, args : Array(String)?)
    compile?(solver, option)
    system "oj g/o -c '#{execute_command(solver, nil)}' #{args ? %["${@}" ] : ""}", args
  end

  def self.hack(hack : Path, hack_option : String?,
                generator : Path, generator_option : String?,
                solver : Path, solver_option : String?,
                args : Array(String)?)
    compile?(hack, hack_option) || OIJ.error("Compile error: #{hack}")
    compile?(generator, generator_option) || OIJ.error("Compile error: #{generator}")
    compile?(solver, solver_option) || OIJ.error("Compile error: #{solver}")
    system "oj g/i --hack-expected '#{execute_command(solver, nil)}' --hack '#{execute_command(hack, nil)}' '#{execute_command(generator, nil)}' #{args ? %["${@}" ] : ""}"
  end
end
