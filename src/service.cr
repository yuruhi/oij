require "yaml"
require "./utility"

module OIJ
  abstract struct Problem
    abstract def succ
    abstract def pred
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

  struct AtCoderProblem < Problem
    getter contest : String, problem : String

    def initialize(@contest, @problem)
    end

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      atcoder = config.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
                OIJ.error("Not found [path][atcoder] in config")
      if directory.parent.parent == atcoder
        AtCoderProblem.new directory.parent.basename, directory.basename
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://atcoder.jp/contests/(.+)/tasks/(.+)$]
        AtCoderProblem.new $1, $2
      end
    end

    def succ
      next_problem = problem[...-1] + problem[-1].succ
      AtCoderProblem.new contest, next_problem
    end

    def pred
      next_problem = problem[...-1] + problem[-1].pred
      AtCoderProblem.new contest, next_problem
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

  struct YukicoderProblem < Problem
    getter number : Int32

    def initialize(@number)
    end

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      yukicoder = config.dig?("path", "yukicoder").try { |s| Path[s.as_s] } ||
                  OIJ.error("Not found [path][yukicoder] in config")
      if directory.parent == yukicoder
        YukicoderProblem.new directory.basename.to_i
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://yukicoder.me/problems/(\d+)$]
        YukicoderProblem.new $1.to_i
      end
    end

    def succ
      YukicoderProblem.new number + 1
    end

    def pred
      YukicoderProblem.new number - 1
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
