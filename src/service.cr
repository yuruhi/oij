require "yaml"
require "json"
require "./utility"
require "./api"

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

    def succ(strict = false)
      if strict
        url = to_url
        contest_json = OIJ.oj_api("get-contest", url)
        problems = contest_json["problems"].as_a
        index = problems.index { |problem| problem["url"].as_s == url }.not_nil!
        if next_problem = problems[index + 1]?
          AtCoderProblem.from_url?(next_problem["url"].as_s).not_nil!
        else
          OIJ.error("Not found next problem for #{url}")
        end
      else
        next_problem = problem[...-1] + problem[-1].succ
        AtCoderProblem.new contest, next_problem
      end
    end

    def pred(strict = false)
      if strict
        url = to_url
        contest_json = OIJ.oj_api("get-contest", url)
        problems = contest_json["problems"].as_a
        index = problems.index { |problem| problem["url"].as_s == url }.not_nil!
        if index > 0
          prev_problem = problems[index - 1]
          AtCoderProblem.from_url?(prev_problem["url"].as_s).not_nil!
        else
          OIJ.error("Not found previous problem for #{url}")
        end
      else
        prev_problem = problem[...-1] + problem[-1].pred
        AtCoderProblem.new contest, prev_problem
      end
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

    def succ(strict = false)
      YukicoderProblem.new number + 1
    end

    def pred(strict = false)
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

  struct CodeforcesProblem < Problem
    getter contest : String, problem : String

    def initialize(@contest, @problem)
    end

    def self.from_directory?(directory : Path, config : YAML::Any) : self?
      codeforces = config.dig?("path", "codeforces").try { |s| Path[s.as_s] } ||
                   OIJ.error("Not found [path][codeforces] in config")
      if directory.parent.parent == codeforces
        CodeforcesProblem.new directory.parent.basename, directory.basename
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://codeforces.com/contest/(.+)/problem/(.+)$]
        CodeforcesProblem.new $1, $2
      end
    end

    def succ(strict = false)
      if strict
        url = to_url
        contest_json = OIJ.oj_api("get-contest", url)
        problems = contest_json["problems"].as_a
        index = problems.index { |problem| problem["url"].as_s == url }.not_nil!
        if next_problem = problems[index + 1]?
          CodeforcesProblem.from_url?(next_problem["url"].as_s).not_nil!
        else
          OIJ.error("Not found next problem for #{url}")
        end
      end
      next_problem = problem[...-1] + problem[-1].succ
      CodeforcesProblem.new contest, next_problem
    end

    def pred(strict = false)
      if strict
        url = to_url
        contest_json = OIJ.oj_api("get-contest", url)
        problems = contest_json["problems"].as_a
        index = problems.index { |problem| problem["url"].as_s == url }.not_nil!
        if index > 0
          prev_problem = problems[index - 1]
          CodeforcesProblem.from_url?(prev_problem["url"].as_s).not_nil!
        else
          OIJ.error("Not found previous problem for #{url}")
        end
      else
        next_problem = problem[...-1] + problem[-1].pred
        CodeforcesProblem.new contest, next_problem
      end
    end

    def to_directory(config : YAML::Any) : Path
      codeforces = config.dig?("path", "codeforces").try { |s| Path[s.as_s] } ||
                   OIJ.error("Not found [path][codeforces] in config")
      codeforces / contest / problem
    end

    def to_url : String
      "https://codeforces.com/contest/#{contest}/problem/#{problem}"
    end
  end
end
