require "yaml"

module OIJ
  class Config
    def self.get
      YAML.parse File.new("/home/yuruhiya/programming/oij/config/oij.yml")
    end
  end
end
