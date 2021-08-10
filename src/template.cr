module OIJ
  def self.generate_template(ext : String, config : YAML::Any) : Nil
    if template_name = config.dig?("template", ext)
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

  def self.generate_all_templates(config : YAML::Any) : Nil
    template = config["template"]? || error("Not found template in config")
    template.as_h.each_key do |ext|
      generate_template(ext.as_s, config)
    end
  end
end
