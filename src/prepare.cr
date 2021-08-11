require "./config"
require "./service/service"

module OIJ
  def self.prepare(directory : Path, config : YAML::Any) : Nil
    unless Dir.exists?(directory)
      Dir.mkdir(directory)
    end
    Dir.cd(directory)
    download(config)
    generate_all_templates(config)
  end

  def self.prepare(url : String, config : YAML::Any) : Nil
    directory = Problem.from_url?(url).try(&.to_directory(config)) ||
                error("Invalid url: #{url}")
    prepare(directory, config)
  end

  def self.prepare_contest(directory : Path, config : YAML::Any) : Nil
    problems = Contest.from_directory?(directory, config).try(&.problems) ||
               error("Invalid directory: #{directory}")
    problems.each do |problem|
      info("Prepare #{problem.to_url} to #{problem.to_directory(config)}")
      prepare(problem.to_directory(config), config)
      STDERR.puts
    end
  end

  def self.prepare_contest(url : String, config : YAML::Any) : Nil
    problems = Contest.from_url?(url).try(&.problems) ||
               error("Invalid url: #{url}")
    problems.each do |problem|
      info("Prepare #{problem.to_url} to #{problem.to_directory(config)}")
      prepare(problem.to_directory(config), config)
      STDERR.puts
    end
  end
end
