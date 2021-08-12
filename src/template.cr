require "./config"

module OIJ
  def self.generate_template(ext : String) : Nil
    template, name = OIJ::Config.template(ext) {
      OIJ.warning("Not found template file for .#{ext}"); return
    }
    if File.exists?(template)
      if !File.exists?(name)
        File.copy(template, name)
        OIJ.info("Generate template file in #{name.expand}")
      else
        OIJ.warning("File is already exists: #{name}")
      end
    else
      OIJ.error("Not found template file: #{template}")
    end
  end

  def self.generate_all_templates : Nil
    OIJ::Config.template {
      OIJ.error("Not found template in config")
    }.each_key { |ext|
      generate_template(ext)
    }
  end
end
