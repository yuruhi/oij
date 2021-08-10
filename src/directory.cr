require "yaml"
require "./service"
require "./utility"

module OIJ
  def self.get_next_directory?(directory : Path, config : YAML::Any) : Path?
    Problem.from_directory?(directory, config).try &.succ.to_directory(config)
  end

  def self.get_next_directory(directory : Path, config : YAML::Any) : Path
    get_next_directory?(directory, config) || error("Not found next url for #{directory}")
  end

  def self.get_prev_directory?(directory : Path, config : YAML::Any) : Path?
    Problem.from_directory?(directory, config).try &.pred.to_directory(config)
  end

  def self.get_prev_directory(directory : Path, config : YAML::Any) : Path
    get_prev_directory?(directory, config) || error("Not found prev url for #{directory}")
  end
end
