module OIJ
  def self.generate_template(ext : String) : Nil
    if template_name = OIJ::Config.get.dig?("template", ext)
      template, name = template_name.as_a
      template, name = Path[template.as_s], Path[name.as_s]
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
    else
      warning("Not found template file for .#{ext}")
    end
  end

  def self.generate_all_templates : Nil
    template = OIJ::Config.get["template"]? || error("Not found template in config")
    template.as_h.each_key do |ext|
      generate_template(ext.as_s)
    end
  end
end
