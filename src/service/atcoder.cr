require "./service"

module OIJ
  struct AtCoderProblem < Problem
    getter contest : String, problem : String

    def initialize(@contest, @problem)
    end

    def self.from_directory?(directory : Path) : self?
      atcoder = OIJ::Config.get.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
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

    def to_directory : Path
      atcoder = OIJ::Config.get.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
                OIJ.error("Not found [path][atcoder] in config")
      atcoder / contest / problem
    end

    def to_url : String
      "https://atcoder.jp/contests/#{contest}/tasks/#{problem}"
    end
  end

  struct AtCoderContest < Contest
    getter contest : String

    def self.from_directory?(directory : Path) : self?
      atcoder = OIJ::Config.get.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
                OIJ.error("Not found [path][atcoder] in config")
      if directory.parent == atcoder
        AtCoderContest.new directory.basename
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://atcoder.jp/contests/(.+)$]
        AtCoderContest.new $1
      end
    end

    def initialize(@contest)
    end

    def problems
      contest_json = OIJ.oj_api("get-contest", to_url)
      contest_json["problems"].as_a.map { |problem_json|
        AtCoderProblem.from_url?(problem_json["url"].as_s).not_nil!
      }
    end

    def to_directory : Path
      atcoder = OIJ::Config.get.dig?("path", "atcoder").try { |s| Path[s.as_s] } ||
                OIJ.error("Not found [path][atcoder] in config")
      atcoder / contest
    end

    def to_url : String
      "https://atcoder.jp/contests/#{contest}"
    end
  end
end
