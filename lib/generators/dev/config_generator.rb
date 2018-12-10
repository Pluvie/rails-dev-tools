require 'rails/generators'

module Dev
  module Generators
    
    class ConfigGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates a dev configuration file."

      def copy_config
        template "dev.yml.erb", "dev.yml"
      end

    end

  end
end