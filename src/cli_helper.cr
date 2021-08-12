module OIJ
  macro add_problem_flags
    define_argument url, description: "specify problem url"
    define_flag atcoder, short: a,
      description: "specify atcoder problem"
    define_flag yukicoder : Int32, short: y,
      description: "specify yukicoder problem"
    define_flag codeforces, short: c,
      description: "specify codeforces problem"
    define_flag next : Bool, short: n,
      description: "specify next problem"
    define_flag prev : Bool, short: p,
      description: "specify previous problem"

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
