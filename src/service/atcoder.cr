require "../service"

module OIJ
  struct AtCoderProblem < Problem
    getter contest : String, problem : String

    def initialize(@contest, @problem)
    end

    def self.from_directory?(directory : Path) : self?
      if directory.parent.parent == OIJ::Config.path("atcoder")
        AtCoderProblem.new directory.parent.basename, directory.basename
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://atcoder.jp/contests/(.+)/tasks/(.+)$]
        AtCoderProblem.new $1, $2
      end
    end

    def self.from_argument?(str : String) : self?
      case str.count('/')
      when 0
        if str.count('_') == 1
          AtCoderProblem.new str[0...str.index('_')], str
        end
      when 1
        left, _, right = str.partition('/')
        AtCoderProblem.new left, right
      end
    end

    def self.from_argument(str : String) : self
      from_argument?(str) || OIJ.error("Invalid arguemnt: #{str}")
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
      Path[OIJ::Config.path("atcoder")] / contest / problem
    end

    def to_url : String
      "https://atcoder.jp/contests/#{contest}/tasks/#{problem}"
    end
  end

  struct AtCoderContest < Contest
    getter contest : String

    def self.from_directory?(directory : Path) : self?
      if directory.parent == OIJ::Config.path("atcoder")
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

    def each(&block) : Nil
      contest_json = OIJ.oj_api("get-contest", to_url)
      contest_json["problems"].as_a.each do |problem_json|
        yield AtCoderProblem.from_url(problem_json["url"].as_s)
      end
    end

    def succ(strict = false)
      contest =~ /(.*?)(\d*)$/
      next_contest = $1 + $2.to_i.succ.to_s.rjust($2.size, '0')
      result = AtCoderContest.new(next_contest)
      if strict
        url = result.to_url
        OIJ.error("Invalid contest: #{url}") unless OIJ.oj_api_success?("get-contest", url)
      end
      result
    end

    def pred(strict = false)
      contest =~ /(.*?)(\d*)$/
      prev_contest = $1 + $2.to_i.pred.to_s.rjust($2.size, '0')
      result = AtCoderContest.new(prev_contest)
      if strict
        url = result.to_url
        OIJ.error("Invalid contest: #{url}") unless OIJ.oj_api_success?("get-contest", url)
      end
      result
    end

    def to_directory : Path
      Path[OIJ::Config.path("atcoder")] / contest
    end

    def to_url : String
      "https://atcoder.jp/contests/#{contest}"
    end
  end
end
