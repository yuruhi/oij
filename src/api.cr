require "json"
require "./utility"

module OIJ
  def self.oj_api(command : String, url : String) : JSON::Any
    json = JSON.parse `oj-api #{command} #{url} 2> /dev/null`
    case status = json["status"].as_s
    when "ok"
      json["result"]
    when "error"
      error(json["messages"].as_a.join('\n'))
    else
      raise "Unexpected states: #{status}"
    end
  end
end
