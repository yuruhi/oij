require "yaml"
require "./service"
require "./utility"

module OIJ
  def self.get_url?(directory : Path) : String?
    Problem.from_directory?(directory).try &.to_url
  end

  def self.get_url(directory : Path) : String
    get_url?(directory) || error("Not found url for #{directory}")
  end

  def self.get_next_url?(directory : Path, strict : Bool) : String?
    Problem.from_directory?(directory).try &.succ(strict).to_url
  end

  def self.get_next_url(directory : Path, strict : Bool) : String
    get_next_url?(directory, strict) || error("Not found next url for #{directory}")
  end

  def self.get_prev_url?(directory : Path, strict : Bool) : String?
    Problem.from_directory?(directory).try &.pred(strict).to_url
  end

  def self.get_prev_url(directory : Path, strict : Bool) : String
    get_prev_url?(directory, strict) || error("Not found previous url for #{directory}")
  end
end
