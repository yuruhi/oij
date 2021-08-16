module OIJ
  macro define_problem_flags
    define_argument url, description: "Specify problem url."
    define_flag atcoder, short: a,
      description: "Specify atcoder problem."
    define_flag yukicoder : Int32, short: y,
      description: "Specify yukicoder problem."
    define_flag codeforces, short: c,
      description: "Specify codeforces problem."
    define_flag next : Bool, short: n,
      description: "Specify next problem."
    define_flag prev : Bool, short: p,
      description: "Specify previous problem."
    define_flag strict : Bool, short: s,
      description: "Strict mode."

    def get_problem : Problem
      if url = arguments.url
        Problem.from_url(url)
      elsif atcoder = flags.atcoder
        AtCoderProblem.from_argument(atcoder)
      elsif yukicoder = flags.yukicoder
        YukicoderProblem.new(yukicoder)
      elsif codeforces = flags.codeforces
        CodeforcesProblem.from_argument(codeforces)
      elsif flags.next
        Problem.current.succ(flags.strict)
      elsif flags.prev
        Problem.current.pred(flags.strict)
      else
        Problem.current
      end
    end
  end

  macro define_contest_flags
    define_argument url, description: "Specify contest url."
    define_flag atcoder, short: a,
      description: "Specify atcoder contest."
    define_flag codeforces, short: c,
      description: "Specify codeforces contest."
    define_flag next : Bool, short: n,
      description: "Specify next contest."
    define_flag prev : Bool, short: p,
      description: "Specify previous contest."
    define_flag strict : Bool, short: s,
      description: "Strict mode."

    def get_contest : Contest
      if url = arguments.url
        Contest.from_url(url)
      elsif atcoder = flags.atcoder
        AtCoderContest.new(atcoder)
      elsif codeforces = flags.codeforces
        CodeforcesContest.new(codeforces)
      elsif flags.next
        Contest.current.succ(flags.strict)
      elsif flags.prev
        Contest.current.pred(flags.strict)
      else
        Contest.current
      end
    end
  end

  def self.after_two_hyphens(array : Array(String) = ARGV) : Array(String)?
    if index = array.index("--")
      array[index + 1..]
    end
  end
end
