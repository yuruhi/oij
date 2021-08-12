require "json"
require "./utility"

module OIJ
  def self.oj_api(command : String, url : String) : JSON::Any
    json = JSON.parse `oj-api #{command} #{url} 2> #{File::NULL}`
    case status = json["status"].as_s
    when "ok"
      json["result"]
    when "error"
      OIJ.error("$ oj-api #{command} #{url}") do
        json["messages"].as_a.each { |s| STDERR << "  " << s << '\n' }
      end
    else
      raise "Unexpected states: #{status}"
    end
  end
end
