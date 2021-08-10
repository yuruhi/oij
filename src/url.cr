require "yaml"

module OIJ
  def self.get_url?(directory : Path, config : YAML::Any) : String?
    atcoder, yukicoder = %w[atcoder yukicoder].map { |service|
      config["path"]?.try &.[service]?.try { |s| Path[s.as_s] }
    }
    par = directory.parent
    if par.parent == atcoder
      contest, problem = par.basename, directory.basename
      "https://atcoder.jp/contests/#{contest}/tasks/#{problem}"
    elsif directory.parent == yukicoder
      no = directory.basename
      "https://yukicoder.me/problems/no/#{no}"
    end
  end

  def self.get_url(directory : Path, config : YAML::Any) : String
    get_url?(directory, config) || error("Not found url: #{directory}")
  end
end
