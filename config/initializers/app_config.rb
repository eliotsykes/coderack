require 'yaml'

class AppConfig  

  cattr_accessor :settings

  def self.load
    config_file = Rails.root.join("config", "application.yml")
    if File.exists?(config_file)
      self.settings = YAML.load(File.read(config_file))[Rails.env].with_indifferent_access
    else
      puts "NO APPLICATION.YML FILE. HOPE YOU DO NOT NEED ONE."
      #U# raise "Please create a config file at config/application.yml (use application.yml.example as a template)."
    end
  end

end

AppConfig.load
