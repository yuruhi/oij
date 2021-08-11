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

    def download(silent = false)
      Dir.cd(to_directory)
      system silent ? "oj d #{to_url} > #{File::NULL}" : "oj d #{to_url}"
    end

    def prepare(silent = false)
      unless Dir.exists?(to_directory)
        Dir.mkdir_p(to_directory)
      end
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

    def prepare(silent = true)
      problems.each(&.prepare)
    end
  end
end

require "./*"
