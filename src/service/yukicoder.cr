require "./service"

module OIJ
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
end
