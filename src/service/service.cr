require "yaml"
require "json"
require "../utility"
require "../api"
require "../command"

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
      from_directory?(directory) || OIJ.error("Invalid directory: #{directory}")
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

    def download(silent = false) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        Dir.mkdir(dir)
      end
      Dir.cd(dir)
      success = OIJ.system silent ? "oj d #{to_url} > #{File::NULL}" : "oj d #{to_url}"
      OIJ.warning("Failed to download: #{to_url}") unless success
    end

    def submit(file : Path) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        OIJ.error("No such directory: #{dir}")
      end
      Dir.cd(dir)
      OIJ.system "oj s #{to_url} #{file}"
    end

    def bundle(file : Path) : Nil
      dir = to_directory
      unless Dir.exists?(dir)
        OIJ.error("No such directory: #{dir}")
      end
      Dir.cd(dir)
      OIJ.system "#{OIJ::Config.bundler(file.extension[1..])} #{file}"
    end

    def bundle_and_submit(file : Path) : Nil
      bundled = OIJ.bundled_file(file.expand(to_directory))
      submit(Path[bundled.path])
    end

    def prepare(silent = false) : Nil
      download(silent)
      OIJ.generate_all_templates
    end
  end

  abstract struct Contest
    abstract def problems
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
      from_directory?(directory) || OIJ.error("Invalid directory: #{directory}")
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

    def prepare(silent = true)
      problems.each do |problem|
        OIJ.info("Prepare #{problem.to_url} in #{problem.to_directory}")
        problem.prepare(silent)
        STDERR.puts
      end
    end
  end
end

require "./*"
