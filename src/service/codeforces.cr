require "./service"

module OIJ
  struct CodeforcesProblem < Problem
    getter contest : String, problem : String

    def initialize(@contest, @problem)
    end

    def self.from_directory?(directory : Path) : self?
      if directory.parent.parent == OIJ::Config.path("codeforces")
        CodeforcesProblem.new directory.parent.basename, directory.basename
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://codeforces.com/contest/(.+)/problem/(.+)$]
        CodeforcesProblem.new $1, $2
      end
    end

    def self.from_argument?(str : String) : self?
      if str.count('/') == 1
        left, _, right = str.partition('/')
        CodeforcesProblem.new left, right
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

    def to_directory : Path
      Path[OIJ::Config.path("codeforces")] / contest / problem
    end

    def to_url : String
      "https://codeforces.com/contest/#{contest}/problem/#{problem}"
    end
  end

  struct CodeforcesContest < Contest
    getter contest : String

    def self.from_directory?(directory : Path) : self?
      if directory.parent == OIJ::Config.path("codeforces")
        CodeforcesContest.new directory.basename
      end
    end

    def self.from_url?(url : String) : self?
      if url =~ %r[^https://codeforces.com/contest/(.+)$]
        CodeforcesContest.new $1
      end
    end

    def initialize(@contest)
    end

    def each(&block) : Nil
      contest_json = OIJ.oj_api("get-contest", to_url)
      contest_json["problems"].as_a.each do |problem_json|
        yield CodeforcesProblem.from_url?(problem_json["url"].as_s).not_nil!
      end
    end

    def succ(strict = false)
      next_contest = contest.to_i.succ.to_s
      result = CodeforcesContest.new(next_contest)
      if strict
        url = result.to_url
        OIJ.error("Invalid contest: #{url}") unless OIJ.oj_api_success?("get-contest", url)
      end
      result
    end

    def pred(strict = false)
      prev_contest = contest.to_i.pred.to_s
      result = CodeforcesContest.new(prev_contest)
      if strict
        url = result.to_url
        OIJ.error("Invalid contest: #{url}") unless OIJ.oj_api_success?("get-contest", url)
      end
      result
    end

    def to_directory : Path
      Path[OIJ::Config.path("codeforces")] / contest
    end

    def to_url : String
      "https://codeforces.com/contest/#{contest}"
    end
  end
end
