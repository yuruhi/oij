require "yaml"
require "json"
require "./utility"
require "./config"
require "./api"
require "./command"

module OIJ
  abstract struct Problem
    abstract def succ(strict = false)
    abstract def pred(strict = false)
    abstract def to_directory : Path
    abstract def to_url : String

    def self.from_directory?(directory : Path) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_directory?(directory)
        return service if service
      {% end %}
      nil
    end

    def self.from_directory(directory : Path) : self
      from_directory?(directory) || OIJ.error("Invalid problem directory: #{directory}")
    end

    def self.from_url?(url : String) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_url?(url)
        return service if service
      {% end %}
      nil
    end

    def self.from_url(url : String) : self?
      from_url?(url) || OIJ.error("Invalid url: #{url}")
    end

    def self.current : self
      from_directory(Path[Dir.current])
    end

    def download(oj_args : Array(String)?, *, silent : Bool) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        Dir.mkdir_p(dir)
        OIJ.info("Make directory: #{dir}")
      end
      Dir.cd(dir)

      args = ["download", to_url]
      args.concat oj_args if oj_args
      OIJ.info_run("oj", args)
      Process.run("oj", args, output: silent ? Process::Redirect::Close : Process::Redirect::Inherit, error: Process::Redirect::Inherit)

      OIJ.warning("Failed to download: #{to_url}") unless $?.success?
    end

    def submit(file : Path, oj_args : Array(String)?) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        OIJ.error("No such directory: #{dir}")
      end
      Dir.cd(dir)

      args = ["submit", to_url, file.to_s]
      args.concat oj_args if oj_args
      OIJ.info_run("oj", args)
      Process.run("oj", args, input: Process::Redirect::Inherit, output: Process::Redirect::Inherit, error: Process::Redirect::Inherit)
    end

    def bundle(file : Path) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        OIJ.error("No such directory: #{dir}")
      end
      Dir.cd(dir)

      command = OIJ::Config.bundler(file.extension[1..]).replace_variables(file)
      OIJ.info_run(command)
      system command
    end

    def bundle_and_submit(file : Path, oj_args : Array(String)?) : Nil
      bundled = OIJ.bundled_file(file.expand(to_directory))
      submit(Path[bundled.path], oj_args)
    end

    def prepare(oj_args : Array(String)?, *, silent : Bool) : Nil
      download(oj_args, silent: silent)
      OIJ.generate_all_templates
    end
  end

  abstract struct Contest
    abstract def succ(strict = false)
    abstract def pred(strict = false)
    abstract def to_directory : Path
    abstract def to_url : String

    def self.from_directory?(directory : Path) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_directory?(directory)
        return service if service
      {% end %}
      nil
    end

    def self.from_directory(directory : Path) : self
      from_directory?(directory) || OIJ.error("Invalid contest directory: #{directory}")
    end

    def self.from_url?(url : String) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_url?(url)
        return service if service
      {% end %}
      nil
    end

    def self.from_url(url : String) : self?
      from_url?(url) || OIJ.error("Invalid url: #{url}")
    end

    def self.current : self
      from_directory(Path[Dir.current])
    end

    def download(oj_args : Array(String)?, *, silent : Bool)
      each do |problem|
        OIJ.info("Download #{problem.to_url} in #{problem.to_directory}")
        problem.download(oj_args, silent: silent)
        STDERR.puts
      end
    end

    def prepare(oj_args : Array(String)?, *, silent : Bool)
      each do |problem|
        OIJ.info("Prepare #{problem.to_url} in #{problem.to_directory}")
        problem.prepare(oj_args, silent: silent)
        STDERR.puts
      end
    end
  end
end

require "./service/*"
