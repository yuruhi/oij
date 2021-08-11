module OIJ
  def self.generate_template(ext : String) : Nil
    template, name = OIJ::Config.template(ext) {
      warning("Not found template file for .#{ext}"); return
    }
    if File.exists?(template)
      if !File.exists?(name)
        File.copy(template, name)
        info("Generate template file in #{name.expand}")
      else
        warning("Failed to generate template file since file is already exists: #{name}")
      end
    else
      error("Not found template file: #{template}")
    end
  end

  def self.generate_all_templates : Nil
    OIJ::Config.template do
      error("Not found template in config")
    end.each_key do |ext|
      generate_template(ext)
    end
  end
end
