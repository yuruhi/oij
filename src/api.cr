require "json"
require "./utility"

module OIJ
  def self.oj_api(command : String, url : String) : JSON::Any
    process = Process.new "oj-api", [command, url], output: Process::Redirect::Pipe
    json = JSON.parse process.output

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

  def self.oj_api_success?(command : String, url : String) : Bool
    process = Process.new "oj-api", [command, url], output: Process::Redirect::Pipe
    json = JSON.parse process.output

    case status = json["status"].as_s
    when "ok"
      true
    when "error"
      false
    else
      raise "Unexpected states: #{status}"
    end
  end
end
