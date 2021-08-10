require "colorize"

module OIJ
  def self.error(message)
    STDERR.puts "[#{"ERROR".colorize(:red)}] #{message}"
    exit(1)
  end

  def self.info(message)
    STDERR.puts "[#{"INFO".colorize(:blue)}] #{message}"
  end

  def self.system(command : String)
    info("$ #{command}")
    ::system(command)
  end
end
