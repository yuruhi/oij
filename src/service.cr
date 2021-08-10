require "yaml"
require "./utility"

module OIJ
  abstract struct Service
    abstract def succ
    abstract def pred
    abstract def to_directory(config : YAML::Any) : Path
    abstract def to_url : String

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      {% begin %}
        {% for service in @type.all_subclasses %}
          service = {{service}}.from_directory?(directory, config)
          return service if service
        {% end %}
      {% end %}
      nil
    end
  end

  struct AtCoder < Service
    getter contest : String, problem : String

    def initialize(@contest, @problem)
    end

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      atcoder = config.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
                OIJ.error("Not found [path][atcoder] in config")
      if directory.parent.parent == atcoder
        AtCoder.new directory.parent.basename, directory.basename
      end
    end

    def succ
      next_problem = problem[...-1] + problem[-1].succ
      AtCoder.new contest, next_problem
    end

    def pred
      next_problem = problem[...-1] + problem[-1].pred
      AtCoder.new contest, next_problem
    end

    def to_directory(config : YAML::Any) : Path
      atcoder = config.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
                OIJ.error("Not found [path][atcoder] in config")
      atcoder / contest / problem
    end

    def to_url : String
      "https://atcoder.jp/contests/#{contest}/tasks/#{problem}"
    end
  end

  struct Yukicoder < Service
    getter number : Int32

    def initialize(@number)
    end

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      yukicoder = config.dig?("path", "yukicoder").try { |s| Path[s.as_s] } ||
                  OIJ.error("Not found [path][yukicoder] in config")
      if directory.parent == yukicoder
        Yukicoder.new directory.basename.to_i
      end
    end

    def succ
      Yukicoder.new number + 1
    end

    def pred
      Yukicoder.new number - 1
    end

    def to_directory(config : YAML::Any) : Path
      yukicoder = config.dig?("path", "yukicoder").try { |s| Path[s.as_s] } ||
                  OIJ.error("Not found [path][yukicoder] in config")
      yukicoder / number.to_s
    end

    def to_url : String
      "https://yukicoder.me/problems/#{number}"
    end
  end
end
