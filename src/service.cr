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

    def download(*, silent, args) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        Dir.mkdir_p(dir)
        OIJ.info("Make directory: #{dir}")
      end
      Dir.cd(dir)

      cmd = if silent
              "oj d #{to_url} #{args ? %["${@}" ] : ""}> #{File::NULL}"
            else
              "oj d #{to_url} #{args ? %["${@}"] : ""}"
            end
      unless OIJ.system(cmd, args)
        OIJ.warning("Failed to download: #{to_url}")
      end
    end

    def submit(file : Path, * , args) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        OIJ.error("No such directory: #{dir}")
      end
      Dir.cd(dir)
      OIJ.system "oj s #{to_url} #{file} #{args ? %["${@}" ] : ""}", args
    end

    def bundle(file : Path) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        OIJ.error("No such directory: #{dir}")
      end
      Dir.cd(dir)
      OIJ.system "#{OIJ::Config.bundler(file.extension[1..])} #{file}"
    end

    def bundle_and_submit(file : Path, *, args) : Nil
      bundled = OIJ.bundled_file(file.expand(to_directory))
      submit(Path[bundled.path], args: args)
    end

    def prepare(*, silent, args) : Nil
      download(silent: silent, args: args)
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

    def download(*, silent, args)
      each do |problem|
        OIJ.info("Download #{problem.to_url} in #{problem.to_directory}")
        problem.download(silent: silent, args: args)
        STDERR.puts
      end
    end

    def prepare(*, silent, args)
      each do |problem|
        OIJ.info("Prepare #{problem.to_url} in #{problem.to_directory}")
        problem.prepare(silent: silent, args: args)
        STDERR.puts
      end
    end
  end
end

require "./service/*"
