require 'yaml'

module Dev
  class Project

    # @return [String] il nome del progetto.
    attr_accessor :name
    # @return [String] il tipo del progetto (multi folder o single folder).
    attr_accessor :type
    # @return [String] la cartella del progetto.
    attr_accessor :folder
    # @return [Array<String>] le main apps del progetto.
    attr_accessor :main_apps
    # @return [Array<String>] gli engines del progetto.
    attr_accessor :engines

    def initialize(config_file)
      config = YAML.load_file(config_file).deep_symbolize_keys!
      self.name = config[:dev][:project_name]
      self.type = config[:dev][:project_type]
      self.folder = config[:dev][:project_folder]
      if self.type == :multi
        self.main_apps = config[:dev][:main_apps] || []
        self.engines = config[:dev][:engines] || []
      else
        self.main_apps = [ self.name ]
        self.engines = []
      end
    end

    ##
    # Ritorna tutte le app del progetto.
    #
    # @return [Array<String>] le app del progetto.
    def apps
      self.main_apps + self.engines
    end

    ##
    # Sposta la directory corrente nella cartella
    # dell'app specificata.
    #
    # @return [nil]
    def chdir_app(app_name)
      if self.type == :multi
        if app_name.in? self.main_apps
          Dir.chdir "#{project.folder}/main_apps/#{app_name}"
        elsif app_name.in? self.engines
          Dir.chdir "#{project.folder}/engines/#{app_name}"
        end
      elsif self.type == :single
        Dir.chdir project.folder
      end
    end
    
  end
end
