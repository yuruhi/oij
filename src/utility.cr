require "colorize"

module OIJ
  private def self.put_message(title, color, message) : Nil
    STDERR << '[' << title.colorize(color) << ']' << ' ' << message << '\n'
  end

  def self.error(message)
    put_message("ERROR", :red, message)
    exit(1)
  end

  def self.error(message, &block)
    put_message("ERROR", :red, message)
    yield
    exit(1)
  end

  def self.warning(message)
    put_message("WARING", :yellow, message)
  end

  def self.info(message)
    put_message("INFO", :blue, message)
  end

  def self.info_run(command : String, args : Enumerable(String)? = nil, shell : Bool = false)
    OIJ.info "$ #{Crystal::System::Process.prepare_args(command, args, shell).join(' ')}"
  end
end
