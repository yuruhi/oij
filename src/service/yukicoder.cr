require "./service"

module OIJ
  struct YukicoderProblem < Problem
    getter number : Int32

    def initialize(@number)
    end

    def self.from_directory?(directory : Path) : self?
      if directory.parent == OIJ::Config.path("yukicoder")
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

    def to_directory : Path
      Path[OIJ::Config.path("yukicoder")] / number.to_s
    end

    def to_url : String
      "https://yukicoder.me/problems/no/#{number}"
    end
  end
end
