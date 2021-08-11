require "yaml"
require "json"
require "../utility"
require "../api"

module OIJ
  abstract struct Problem
    abstract def succ(strict = false)
    abstract def pred(strict = false)
    abstract def to_directory(config : YAML::Any) : Path
    abstract def to_url : String

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_directory?(directory, config)
        return service if service
      {% end %}
      nil
    end

    def self.from_url?(url : String) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_url?(url)
        return service if service
      {% end %}
      nil
    end
  end

  abstract struct Contest
    abstract def problems
    abstract def to_directory(config : YAML::Any) : Path
    abstract def to_url : String

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_directory?(directory, config)
        return service if service
      {% end %}
      nil
    end

    def self.from_url?(url : String) : self?
      {% for service in @type.all_subclasses %}
        service = {{service}}.from_url?(url)
        return service if service
      {% end %}
      nil
    end
  end
end

require "./*"
