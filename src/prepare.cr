require "./config"
require "./service/service"

module OIJ
  def self.prepare(directory : Path) : Nil
    Problem.from_directory(directory).try(&.prepare)
  end

  def self.prepare(url : String) : Nil
    directory = Problem.from_url?(url).try(&.to_directory) ||
                error("Invalid url: #{url}")
    prepare(directory)
  end

  def self.prepare_contest(directory : Path) : Nil
    problems = Contest.from_directory?(directory).try(&.problems) ||
               error("Invalid directory: #{directory}")
    problems.each do |problem|
      info("Prepare #{problem.to_url} to #{problem.to_directory}")
      prepare(problem.to_directory)
      STDERR.puts
    end
  end

  def self.prepare_contest(url : String) : Nil
    problems = Contest.from_url?(url).try(&.problems) ||
               error("Invalid url: #{url}")
    problems.each do |problem|
      info("Prepare #{problem.to_url} to #{problem.to_directory}")
      prepare(problem.to_directory)
      STDERR.puts
    end
  end
end
