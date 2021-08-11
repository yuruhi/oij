require "yaml"
require "./service"
require "./utility"

module OIJ
  def self.get_next_directory?(directory : Path) : Path?
    Problem.from_directory?(directory).try &.succ.to_directory
  end

  def self.get_next_directory(directory : Path) : Path
    get_next_directory?(directory) || error("Not found next url for #{directory}")
  end

  def self.get_prev_directory?(directory : Path) : Path?
    Problem.from_directory?(directory).try &.pred.to_directory
  end

  def self.get_prev_directory(directory : Path) : Path
    get_prev_directory?(directory) || error("Not found prev url for #{directory}")
  end
end
