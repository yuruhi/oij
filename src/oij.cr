require "admiral"
require "./command"
require "./testcase"
require "./template"
require "./service/service"
require "./cli_helper"

module OIJ
  class CLI < Admiral::Command
    define_help short: h, description: "oij is a competitive programming helper"
    define_version "0.1.0", short: v

    class Compile < Admiral::Command
      define_help short: h, description: "compile given file"
      define_argument file, required: true

      def run
        OIJ.compile(Path[arguments.file])
      end
    end

    class Execute < Admiral::Command
      define_help short: h, description: "execute given file"
      define_argument file, required: true
      define_argument input_file

      def run
        OIJ.execute(Path[arguments.file], arguments.input_file)
      end
    end

    class CompileAndExecute < Admiral::Command
      define_help short: h, description: "compile and execute given file"
      define_argument file, required: true
      define_argument input_file

      def run
        OIJ.run(Path[arguments.file], arguments.input_file)
      end
    end

    class Test < Admiral::Command
      define_help short: h, description: "test given file"
      define_argument file, required: true

      def run
        OIJ.test(Path[arguments.file])
      end
    end

    class CompileAndTest < Admiral::Command
      define_help short: h, description: "compile and test given file"
      define_argument file, required: true

      def run
        OIJ.compile_and_test(Path[arguments.file])
      end
    end

    class EditTestcase < Admiral::Command
      define_help short: h, description: "edit given testcase"
      define_argument name, required: true

      define_flag dir : String, default: "test", short: d,
        description: "a directory name for testcases"

      def run
        OIJ.edit_testcase(arguments.name, Path[flags.dir])
      end
    end

    class PrintTestcase < Admiral::Command
      define_help short: h, description: "print given testcase"
      define_argument name, required: true
      define_flag dir : String, default: "test", short: d,
        description: "a directory name for testcases (default: test)"

      def run
        OIJ.print_testcase(arguments.name, Path[flags.dir])
      end
    end

    class GetURL < Admiral::Command
      define_help short: h, description: "print url of given problem"
      define_flag strict : Bool, short: s, description: "strict mode"
      OIJ.add_problem_flags

      def run
        puts get_problem.to_url
      end
    end

    class GetDirectory < Admiral::Command
      define_help short: h, description: "print directory of given problem"
      define_flag strict : Bool, short: s, description: "strict mode"
      OIJ.add_problem_flags

      def run
        puts get_problem.to_directory
      end
    end

    class Download < Admiral::Command
      define_help short: h, description: "download testcases"
      define_flag silent : Bool, short: s, description: "silent mode"
      OIJ.add_problem_flags

      def run
        get_problem.download(silent: flags.silent, args: OIJ.after_two_hyphens)
      end
    end

    class Bundle < Admiral::Command
      define_help short: h, description: "bundle given file"
      define_argument file, required: true

      def run
        Problem.current.bundle(Path[arguments.file])
      end
    end

    class Submit < Admiral::Command
      define_help short: h, description: "submit given code"
      define_argument file, required: true

      def run
        Problem.current.bundle_and_submit(Path[arguments.file])
      end
    end

    class Template < Admiral::Command
      define_help short: h, description: "generate templates"
      define_flag ext : Array(String), short: e,
        description: "specify generated extensions (if not given, generate all templates)"

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

    class Prepare < Admiral::Command
      define_help short: h, description: "prepare given problem"
      OIJ.add_problem_flags

      def run
        problem = get_problem
        problem.prepare(silent: true, args: OIJ.after_two_hyphens)
        puts problem.to_directory
      end
    end

    class PrepareContest < Admiral::Command
      define_help short: h, description: "prepare contest"
      define_argument url, description: "specify contest url"
      define_flag atcoder, short: a,
        description: "specify atcoder contest"
      define_flag codeforces, short: c,
        description: "specify codeforces contest"

      def run
        contest =
          if url = arguments.url
            Contest.from_url(url)
          elsif atcoder = flags.atcoder
            AtCoderContest.new(atcoder)
          elsif codeforces = flags.codeforces
            CodeforcesContest.new(codeforces)
          else
            Contest.current
          end
        contest.prepare(silent: true, args: OIJ.after_two_hyphens)
      end
    end

    register_sub_command compile, Compile
    register_sub_command exe, Execute
    register_sub_command run, CompileAndExecute
    register_sub_command test, Test
    register_sub_command t, CompileAndTest
    register_sub_command "edit-test", EditTestcase, short: "et"
    register_sub_command "print-test", PrintTestcase, short: "pt"
    register_sub_command url, GetURL
    register_sub_command dir, GetDirectory
    register_sub_command download, Download, short: "d"
    register_sub_command bundle, Bundle
    register_sub_command submit, Submit, short: "s"
    register_sub_command template, Template
    register_sub_command prepare, Prepare, short: "p"
    register_sub_command "prepare-contest", PrepareContest, short: "pc"

    def run
      puts help
    end
  end
end
