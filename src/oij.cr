require "./cli_helper"
require "./command"
require "./random_test"
require "./testcase"
require "./template"
require "./service"
require "./file"

module OIJ
  class CLI < Admiral::Command
    define_help short: h, description: "oij is a competitive programming helper."
    define_version "0.1.0", short: v

    class Compile < Admiral::Command
      define_help short: h, description: "Compile given file."
      define_argument file : Path
      define_flag option, short: o

      def run
        file = arguments.file || OIJ.guess_program_file
        OIJ.compile(file, flags.option)
      end
    end

    class Execute < Admiral::Command
      define_help short: h, description: "Execute given file."
      define_argument file
      define_argument input_file
      define_flag option, short: o

      def run
        if (file = arguments.file).nil?
          OIJ.execute(OIJ.guess_program_file, flags.option, nil)
        elsif (input = arguments.input_file).nil?
          if OIJ.program_file?(file)
            OIJ.execute(Path[file], flags.option, nil)
          else # file is input file
            OIJ.execute(OIJ.guess_program_file, flags.option, file)
          end
        else
          OIJ.execute(Path[file], flags.option, input)
        end
      end
    end

    class CompileAndExecute < Admiral::Command
      define_help short: h, description: "Compile and execute given file."
      define_argument file, required: true
      define_argument input_file
      define_flag option, short: o

      def run
        if (file = arguments.file).nil?
          OIJ.run(OIJ.guess_program_file, flags.option, nil)
        elsif (input = arguments.input_file).nil?
          if OIJ.program_file?(file)
            OIJ.run(Path[file], flags.option, nil)
          else # file is input file
            OIJ.run(OIJ.guess_program_file, flags.option, file)
          end
        else
          OIJ.run(Path[file], flags.option, input)
        end
      end
    end

    class Test < Admiral::Command
      define_help short: h, description: "Test given file."
      define_argument file : Path
      define_flag option, short: o

      def run
        file = arguments.file || OIJ.guess_program_file
        OIJ.test(file, flags.option, OIJ.after_two_hyphens)
      end
    end

    class CompileAndTest < Admiral::Command
      define_help short: h, description: "Compile and test given file."
      define_argument file : Path
      define_flag option, short: o

      def run
        file = arguments.file || OIJ.guess_program_file
        OIJ.compile_and_test(file, flags.option, OIJ.after_two_hyphens)
      end
    end

    class Bundle < Admiral::Command
      define_help short: h, description: "Bundle given file"
      define_argument file : Path

      def run
        file = arguments.file || OIJ.guess_program_file
        Problem.current.bundle(file)
      end
    end

    class Submit < Admiral::Command
      define_help short: h, description: "Submit bundled file."
      define_argument file : Path

      def run
        file = arguments.file || OIJ.guess_program_file
        Problem.current.bundle_and_submit(file, OIJ.after_two_hyphens)
      end
    end

    class EditTestcase < Admiral::Command
      define_help short: h, description: "Edit given testcase."
      define_argument name, required: true

      define_flag dir : Path, default: Path["test"], short: d,
        description: "Specify directory name for testcases."

      def run
        OIJ.edit_testcase(arguments.name, flags.dir)
      end
    end

    class PrintTestcase < Admiral::Command
      define_help short: h, description: "Print given testcase."
      define_argument name, required: true
      define_flag dir : Path, default: Path["test"], short: d,
        description: "Specify directory name for testcases."

      def run
        OIJ.print_testcase(arguments.name, flags.dir)
      end
    end

    class ProblemURL < Admiral::Command
      define_help short: h, description: "Print url of given problem."
      OIJ.define_problem_flags

      def run
        puts get_problem.to_url
      end
    end

    class ContestURL < Admiral::Command
      define_help short: h, description: "Print url of given contest."
      OIJ.define_contest_flags

      def run
        puts get_contest.to_url
      end
    end

    class PorblemDirectory < Admiral::Command
      define_help short: h, description: "Print directory of given problem."
      OIJ.define_problem_flags

      def run
        puts get_problem.to_directory
      end
    end

    class ContestDirectory < Admiral::Command
      define_help short: h, description: "Print directory of given contest."
      OIJ.define_contest_flags

      def run
        puts get_contest.to_directory
      end
    end

    class DownloadProblem < Admiral::Command
      define_help short: h, description: "Download testcases of given problem."
      define_flag silent : Bool, short: s, description: "Silent mode."
      OIJ.define_problem_flags

      def run
        get_problem.download(OIJ.after_two_hyphens, silent: flags.silent)
      end
    end

    class DownloadContest < Admiral::Command
      define_help short: h, description: "Download testcases of given contest."
      define_flag silent : Bool, short: s, description: "Silent mode."
      OIJ.define_contest_flags

      def run
        get_contest.download(OIJ.after_two_hyphens, silent: flags.silent)
      end
    end

    class GenerateTemplate < Admiral::Command
      define_help short: h, description: "Generate templates."
      define_flag ext : Array(String), short: e,
        description: "Specify generated extensions (if not given, generate all templates)."

      def run
        if flags.ext.empty?
          OIJ.generate_all_templates
        else
          flags.ext.each do |extension|
            OIJ.generate_template(extension)
          end
        end
      end
    end

    class PrepareProblem < Admiral::Command
      define_help short: h, description: "Prepare for given problem."
      OIJ.define_problem_flags

      def run
        problem = get_problem
        problem.prepare(OIJ.after_two_hyphens, silent: true)
        puts problem.to_directory
      end
    end

    class PrepareContest < Admiral::Command
      define_help short: h, description: "Prepare for given contest."
      OIJ.define_contest_flags

      def run
        get_contest.prepare(OIJ.after_two_hyphens, silent: true)
      end
    end

    class GenerateInput < Admiral::Command
      define_help short: h, description: "Generate input"
      define_argument generator : Path, required: true
      define_argument count : Int32, default: 100
      define_flag option, short: o

      def run
        OIJ.generate_input(arguments.generator, flags.option, arguments.count, OIJ.after_two_hyphens)
      end
    end

    class GenerateOutput < Admiral::Command
      define_help short: h, description: "Generate output"
      define_argument solver : Path, required: true
      define_flag option, short: o

      def run
        OIJ.generate_output(arguments.solver, flags.option, OIJ.after_two_hyphens)
      end
    end

    class GenerateHackCase < Admiral::Command
      define_help short: h, description: "Find hack case"
      define_argument hack : Path, required: true, description: "Specify your wrong solution."
      define_argument generator : Path, required: true, description: "Specify program to generate test cases."
      define_argument solver : Path, required: true, description: "Specify program to generate correct answers."
      define_flag hack_option, short: h
      define_flag generator_option, short: g
      define_flag solver_option, short: s
      define_flag option, short: o

      def run
        if flags.option
          OIJ.hack(arguments.hack, flags.option,
            arguments.generator, flags.option,
            arguments.solver, flags.option,
            OIJ.after_two_hyphens)
        else
          OIJ.hack(arguments.hack, flags.hack_option,
            arguments.generator, flags.generator_option,
            arguments.solver, flags.solver_option,
            OIJ.after_two_hyphens)
        end
      end
    end

    register_sub_command "compile", Compile
    register_sub_command "exe", Execute
    register_sub_command "run", CompileAndExecute
    register_sub_command "test", Test
    register_sub_command "t", CompileAndTest
    register_sub_command "bundle", Bundle
    register_sub_command "submit", Submit, short: "s"

    register_sub_command "edit-test", EditTestcase, short: "et"
    register_sub_command "print-test", PrintTestcase, short: "pt"

    register_sub_command "url", ProblemURL
    register_sub_command "url-contest", ContestURL, short: "urlc"

    register_sub_command "dir", PorblemDirectory
    register_sub_command "dir-contest", ContestDirectory, short: "dirc"

    register_sub_command "download", DownloadProblem, short: "d"
    register_sub_command "download-contest", DownloadContest, short: "dc"
    register_sub_command "template", GenerateTemplate
    register_sub_command "prepare", PrepareProblem, short: "p"
    register_sub_command "prepare-contest", PrepareContest, short: "pc"

    register_sub_command "generate-input", GenerateInput, short: "gi"
    register_sub_command "generate-output", GenerateOutput, short: "go"
    register_sub_command "hack", GenerateHackCase

    def run
      puts help
    end
  end
end
