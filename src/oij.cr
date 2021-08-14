require "admiral"
require "./command"
require "./testcase"
require "./template"
require "./service"
require "./cli_helper"

module OIJ
  class CLI < Admiral::Command
    define_help short: h, description: "oij is a competitive programming helper."
    define_version "0.1.0", short: v

    class Compile < Admiral::Command
      define_help short: h, description: "Compile given file."
      define_argument file, required: true
      define_flag option, short: o

      def run
        OIJ.compile(Path[arguments.file], flags.option)
      end
    end

    class Execute < Admiral::Command
      define_help short: h, description: "Execute given file."
      define_argument file, required: true
      define_argument input_file

      def run
        OIJ.execute(Path[arguments.file], arguments.input_file)
      end
    end

    class CompileAndExecute < Admiral::Command
      define_help short: h, description: "Compile and execute given file."
      define_argument file, required: true
      define_argument input_file
      define_flag option, short: o

      def run
        OIJ.run(Path[arguments.file], arguments.input_file, flags.option)
      end
    end

    class Test < Admiral::Command
      define_help short: h, description: "Test given file."
      define_argument file, required: true

      def run
        OIJ.test(Path[arguments.file])
      end
    end

    class CompileAndTest < Admiral::Command
      define_help short: h, description: "Compile and test given file."
      define_argument file, required: true
      define_flag option, short: o

      def run
        OIJ.compile_and_test(Path[arguments.file], flags.option)
      end
    end

    class EditTestcase < Admiral::Command
      define_help short: h, description: "Edit given testcase."
      define_argument name, required: true

      define_flag dir : String, default: "test", short: d,
        description: "Specify directory name for testcases."

      def run
        OIJ.edit_testcase(arguments.name, Path[flags.dir])
      end
    end

    class PrintTestcase < Admiral::Command
      define_help short: h, description: "Print given testcase."
      define_argument name, required: true
      define_flag dir : String, default: "test", short: d,
        description: "Specify directory name for testcases."

      def run
        OIJ.print_testcase(arguments.name, Path[flags.dir])
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

    class Bundle < Admiral::Command
      define_help short: h, description: "Bundle given file"
      define_argument file, required: true

      def run
        Problem.current.bundle(Path[arguments.file])
      end
    end

    class Submit < Admiral::Command
      define_help short: h, description: "Submit bundled file."
      define_argument file, required: true

      def run
        Problem.current.bundle_and_submit(Path[arguments.file], args: OIJ.after_two_hyphens)
      end
    end

    class DownloadProblem < Admiral::Command
      define_help short: h, description: "Download testcases of given problem."
      define_flag silent : Bool, short: s, description: "Silent mode."
      OIJ.define_problem_flags

      def run
        get_problem.download(silent: flags.silent, args: OIJ.after_two_hyphens)
      end
    end

    class DownloadContest < Admiral::Command
      define_help short: h, description: "Download testcases of given contest."
      define_flag silent : Bool, short: s, description: "Silent mode."
      OIJ.define_contest_flags

      def run
        get_contest.download(silent: flags.silent, args: OIJ.after_two_hyphens)
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
        problem.prepare(silent: true, args: OIJ.after_two_hyphens)
        puts problem.to_directory
      end
    end

    class PrepareContest < Admiral::Command
      define_help short: h, description: "Prepare for given contest."
      OIJ.define_contest_flags

      def run
        get_contest.prepare(silent: true, args: OIJ.after_two_hyphens)
      end
    end

    register_sub_command "compile", Compile
    register_sub_command "exe", Execute
    register_sub_command "run", CompileAndExecute
    register_sub_command "test", Test
    register_sub_command "t", CompileAndTest

    register_sub_command "edit-test", EditTestcase, short: "et"
    register_sub_command "print-test", PrintTestcase, short: "pt"

    register_sub_command "url", ProblemURL
    register_sub_command "url-contest", ContestURL, short: "urlc"

    register_sub_command "dir", PorblemDirectory
    register_sub_command "dir-contest", ContestDirectory, short: "dirc"

    register_sub_command "bundle", Bundle
    register_sub_command "submit", Submit, short: "s"

    register_sub_command "download", DownloadProblem, short: "d"
    register_sub_command "download-contest", DownloadContest, short: "dc"
    register_sub_command "template", GenerateTemplate
    register_sub_command "prepare", PrepareProblem, short: "p"
    register_sub_command "prepare-contest", PrepareContest, short: "pc"

    def run
      puts help
    end
  end
end
