module OIJ
  macro add_problem_flags
    define_argument url, description: "specify problem url"
    define_flag atcoder,
      description: "specify atcoder problem",
      long: atcoder, short: a
    define_flag yukicoder : Int32,
      description: "specify yukicoder problem",
      long: yukicoder, short: y
    define_flag codeforces,
      description: "specify codeforces problem",
      long: codeforces, short: c
    define_flag next : Bool,
      description: "specify next problem",
      long: next, short: n
    define_flag prev : Bool,
      description: "specify previous problem",
      long: prev, short: p

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
        Problem.current.succ
      elsif flags.prev
        Problem.current.pred
      else
        Problem.current
      end
    end
  end

  def self.after_two_hyphens(array : Array(String) = ARGV) : Array(String)
    if index = array.index("--")
      array[index + 1..]
    else
      [] of String
    end
  end

  macro delegate_flags(flags)
		{% for arg in flags %}
		  {% if arg.size == 1 %}
			  define_flag {{arg[0]}}
			{% else %}
			  define_flag {{arg[0]}}, {{arg[1].double_splat}}
			{% end %}
		{% end %}

		def delegated_args
			args = [] of String
			{% for arg in flags %}
				{% if arg[0].is_a?(TypeDeclaration) && arg[0].type.stringify == "Bool" %}
					if flags.{{arg[0].var}}
						args << "--{{arg[0].var.stringify.tr("_", "-").id}}"
					end
				{% else %}
					if val = flags.{{arg[0]}}
						args << "--{{arg[0].stringify.tr("_", "-").id}}" << val
					end
				{% end %}
			{% end %}
			args
		end
	end
end
