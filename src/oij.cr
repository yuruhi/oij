require "admiral"
require "./config"
require "./command"
require "./file"
require "./testcase"
require "./url"
require "./template"
require "./directory"
require "./prepare"

module OIJ
  class CLI < Admiral::Command
    define_help description: "oij is a competitive programming helper"
    define_version "0.1.0"

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
      define_help description: "get url"
      define_flag next : Bool,
        description: "get next url for current directory",
        long: next, short: n
      define_flag prev : Bool,
        description: "get previous url for current directory",
        long: prev, short: p
      define_flag strict : Bool,
        description: "strict mode",
        long: strict, short: s

      def run
        if flags.next
          puts OIJ.get_next_url(Path[Dir.current], flags.strict)
        elsif flags.prev
          puts OIJ.get_prev_url(Path[Dir.current], flags.strict)
        else
          puts OIJ.get_url(Path[Dir.current])
        end
      end
    end

    class GetDirectory < Admiral::Command
      define_help description: "get directory for next or previous problem"
      define_flag next : Bool,
        description: "get directory for next problem",
        long: next, short: n
      define_flag prev : Bool,
        description: "get directory for previous problem",
        long: prev, short: p

      def run
        if flags.next
          puts OIJ.get_next_directory(Path[Dir.current])
        elsif flags.prev
          puts OIJ.get_prev_directory(Path[Dir.current])
        end
      end
    end

    class Download < Admiral::Command
      define_help description: "download testcases"

      def run
        OIJ.download
      end
    end

    class Bundle < Admiral::Command
      define_help description: "bundle given file"
      define_argument file, required: true

      def run
        OIJ.bundle(Path[arguments.file])
      end
    end

    class Submit < Admiral::Command
      define_help description: "sumit given code"
      define_argument file, required: true

      def run
        OIJ.bundle_and_submit(Path[arguments.file], Path[Dir.current])
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
      define_help description: "prepare problem"
      define_argument url, description: "specifiy problem url"

      def run
        if url = arguments.url
          Problem.from_url(url).prepare
        else
          Problem.from_directory(Path[Dir.current]).prepare
        end
      end
    end

    class PrepareContest < Admiral::Command
      define_help description: "prepare contest"
      define_argument url, description: "specify contest url"

      def run
        if url = arguments.url
          Contest.from_url(url).prepare
        else
          Contest.from_directory(Path[Dir.current]).prepare
        end
      end
    end

    register_sub_command compile, Compile
    register_sub_command execute, Execute
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
