require "colorize"

module OIJ
  private def self.put_message(title, color, message)
    STDERR << '[' << title.colorize(color) << ']' << ' ' << message << '\n'
  end

  def self.error(message)
    put_message("ERROR", :red, message)
    exit(1)
  end

  def self.warning(message)
    put_message("WARING", :yellow, message)
  end

  def self.info(message)
    put_message("INFO", :blue, message)
  end

  def self.system(command : String)
    info("$ #{command}")
    ::system(command)
  end
end
