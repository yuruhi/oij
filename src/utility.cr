require "colorize"

module OIJ
  private def self.put_message(title, color, message) : Nil
    STDERR << '[' << title.colorize(color) << ']' << ' ' << message << '\n'
  end

  def self.error(message, exit_code = 1)
    put_message("ERROR", :red, message)
    exit(exit_code)
  end

  def self.error(message, exit_code = 1, &block)
    put_message("ERROR", :red, message)
    yield
    exit(exit_code)
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

  def self.exit_with_message(status : Process::Status, &message)
    if status.success?
      exit
    else
      put_message("ERROR", :red, yield)
      exit(status.exit_code)
    end
  end
end
