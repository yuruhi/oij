require "yaml"
require "option_parser"
require "./command"
require "./file"
require "./testcase"
require "./url"
require "./template"

module OIJ
  VERSION = "0.1.0"

  def self.run(args = ARGV)
    config = YAML.parse File.new("/home/yuruhiya/programming/oij/config/oij.yml")

    parser = OptionParser.new
    parser.banner = "oij is a competitive programming helper."

    parser.on("-v", "--version", "show the oij version number") do
      puts "oij #{VERSION}"
      exit
    end
    parser.on("-h", "--help", "show this help message") do
      puts parser
      exit
    end

    parser.on("compile", "compile") do
      parser.banner = "Usage: oij compile file"
      parser.unknown_args do |files|
        file = Path[files[0]]
        compile(file, config)
      end
    end

    parser.on("execute", "execute") do
      parser.banner = "Usage: oij execute file [input_file]"
      parser.unknown_args do |files|
        file = Path[files[0]]
        input_file = files[1]?
        execute(file, input_file, config)
      end
    end

    parser.on("run", "compile and execute") do
      parser.banner = "Usage: oij run file [input_file]"
      parser.unknown_args do |files|
        file = Path[files[0]]
        input_file = files[1]?
        run(file, input_file, config)
      end
    end

    parser.on("test", "test") do
      parser.banner = "Usage: oij test file"
      parser.unknown_args do |files|
        file = Path[files[0]]
        test(file, config)
      end
    end

    parser.on("t", "compile and test") do
      parser.banner = "Usage: oij t file"
      parser.unknown_args do |files|
        file = Path[files[0]]
        compile_and_test(file, config)
      end
    end

    parser.on("et", "edit testcase") do
      parser.banner = "Usage: oij et name"

      dir = Path["test"]
      parser.on("-d DIR", "--dir DIR", "a directory name for testcases (default: test)") do |argument|
        dir = Path[argument]
      end

      parser.unknown_args do |names|
        names.each do |name|
          edit_testcase(name, dir, config)
        end
      end
    end

    parser.on("pt", "print testcase") do
      parser.banner = "Usage: oij pt name"

      dir = Path["test"]
      parser.on("-d DIR", "--dir DIR", "a directory name for testcases (default: test)") do |argument|
        dir = Path[argument]
      end

      parser.unknown_args do |names|
        names.each do |name|
          print_testcase(name, dir, config)
        end
      end
    end

    parser.on("url", "get url for current directory") do
      parser.banner = "Usage: oij url"
      puts get_url(Path[Dir.current], config)
    end

    parser.on("d", "download testcases") do
      parser.banner = "Usage: oij d"
      download(Path[Dir.current], config)
    end

    parser.on("s", "submit code") do
      parser.banner = "Usage: oij s file"
      parser.unknown_args do |files|
        file = Path[files[0]]
        bundle_and_submit(file, Path[Dir.current], config)
      end
    end

    parser.on("template", "generate templates") do
      parser.banner = "Usage: oij template [extension]"
      parser.unknown_args do |extensions|
        if extensions.empty?
          generate_all_templates(config)
        else
          extensions.each { |extension| generate_template(extension, config) }
        end
      end
    end

    parser.on("p", "download testcases and generate templates") do
      parser.banner = "Usage: oij p"
      download(Path[Dir.current], config)
      generate_all_templates(config)
    end

    parser.on("bundle", "bundle") do
      parser.banner = "Usage: oij bundle file"
      parser.unknown_args do |files|
        file = Path[files[0]]
        bundle(file, config)
      end
    end

    parser.parse(args)
  end
end
