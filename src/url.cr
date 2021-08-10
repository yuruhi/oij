require "yaml"
require "./service"
require "./utility"

module OIJ
  def self.get_url?(directory : Path, config : YAML::Any) : String?
    Service.from_directory?(directory, config).try &.to_url
  end

  def self.get_url(directory : Path, config : YAML::Any) : String
    get_url?(directory, config) || error("Not found url for #{directory}")
  end

  def self.get_next_url?(directory : Path, config : YAML::Any) : String?
    Service.from_directory?(directory, config).try &.succ.to_url
  end

  def self.get_next_url(directory : Path, config : YAML::Any) : String
    get_next_url?(directory, config) || error("Not found next url for #{directory}")
  end

  def self.get_prev_url?(directory : Path, config : YAML::Any) : String?
    Service.from_directory?(directory, config).try &.pred.to_url
  end

  def self.get_prev_url(directory : Path, config : YAML::Any) : String
    get_prev_url?(directory, config) || error("Not found prev url for #{directory}")
  end
end
