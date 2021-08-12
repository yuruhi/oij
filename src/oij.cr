require "admiral"
require "./command"
require "./testcase"
require "./template"
require "./service/service"

module OIJ
  class CLI < Admiral::Command
    define_help description: "oij is a competitive programming helper"
    define_version "0.1.0"

    macro add_problem_flags
      define_argument url, description: "specify problem url"
      define_flag atcoder,
        description: "specify atcoder problem",
        long: atcoder, short: a
      define_flag yukicoder : Int32,
        description: "specify yukicoder problem",
        long: yukicoder, short: y
      define_flag codeforces,
        description: "specify codeforces problem",
        long: codeforces, short: c
      define_flag next : Bool,
        description: "specify next problem",
        long: next, short: n
      define_flag prev : Bool,
        description: "specify previous problem",
        long: prev, short: p

      def get_problem : Problem
        if url = arguments.url
          Problem.from_url(url)
        elsif atcoder = flags.atcoder
          AtCoderProblem.from_argument(atcoder)
        elsif yukicoder = flags.yukicoder
          YukicoderProblem.new(yukicoder)
        elsif codeforces = flags.codeforces
          CodeforcesProblem.from_argument(codeforces)
        elsif flags.next
          Problem.current.succ
        elsif flags.prev
          Problem.current.pred
        else
          Problem.current
        end
      end
    end

    class Compile < Admiral::Command
      define_help description: "compile given file"
      define_argument file, required: true

      def run
        OIJ.compile(Path[arguments.file])
      end
    end

    class Execute < Admiral::Command
      define_help description: "execute given file"
      define_argument file, required: true
      define_argument input_file

      def run
        OIJ.execute(Path[arguments.file], arguments.input_file)
      end
    end

    class CompileAndExecute < Admiral::Command
      define_help description: "compile and execute given file"
      define_argument file, required: true
      define_argument input_file

      def run
        OIJ.run(Path[arguments.file], arguments.input_file)
      end
    end

    class Test < Admiral::Command
      define_help description: "test given file"
      define_argument file, required: true

      def run
        OIJ.test(Path[arguments.file])
      end
    end

    class CompileAndTest < Admiral::Command
      define_help description: "compile and test given file"
      define_argument file, required: true

      def run
        OIJ.compile_and_test(Path[arguments.file])
      end
    end

    class EditTestcase < Admiral::Command
      define_help description: "edit given testcase"
      define_argument name, required: true
      define_flag dir : String,
        description: "a directory name for testcases (default: test)",
        default: "test", long: dir, short: d

      def run
        OIJ.edit_testcase(arguments.name, Path[flags.dir])
      end
    end

    class PrintTestcase < Admiral::Command
      define_help description: "print given testcase"
      define_argument name, required: true
      define_flag dir : String,
        description: "a directory name for testcases (default: test)",
        default: "test", long: dir, short: d

      def run
        OIJ.print_testcase(arguments.name, Path[flags.dir])
      end
    end

    class GetURL < Admiral::Command
      define_help description: "print url of given problem"
      CLI.add_problem_flags
      define_flag strict : Bool,
        description: "strict mode",
        long: strict, short: s

      def run
        problem = get_problem
        puts problem.to_url
      end
    end

    class GetDirectory < Admiral::Command
      define_help description: "print directory of given problem"
      define_flag strict : Bool,
        description: "strict mode",
        long: strict, short: s
      CLI.add_problem_flags

      def run
        problem = get_problem
        puts problem.to_directory
      end
    end

    class Download < Admiral::Command
      define_help description: "download testcases"
      CLI.add_problem_flags

      def run
        problem = get_problem
        problem.download
      end
    end

    class Bundle < Admiral::Command
      define_help description: "bundle given file"
      define_argument file, required: true

      def run
        Problem.current.bundle(Path[arguments.file])
      end
    end

    class Submit < Admiral::Command
      define_help description: "submit given code"
      define_argument file, required: true

      def run
        Problem.current.bundle_and_submit(Path[arguments.file])
      end
    end

    class Template < Admiral::Command
      define_help description: "generate templates"
      define_flag ext : Array(String),
        description: "specify generated extensions (if not given, generate all templates)",
        long: ext, short: e

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
      define_help description: "prepare given problem"
      CLI.add_problem_flags

      def run
        problem = get_problem
        problem.prepare(silent: true)
        puts problem.to_directory
      end
    end

    class PrepareContest < Admiral::Command
      define_help description: "prepare contest"
      define_argument url, description: "specify contest url"
      define_flag atcoder,
        description: "specify atcoder contest",
        long: atocder, short: a
      define_flag codeforces,
        description: "specify codeforces contest",
        long: codeforces, short: c

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
        contest.prepare(true)
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
