require 'yaml'

module Dev
  class Project

    # @return [String] il nome del progetto.
    attr_accessor :name
    # @return [String] il tipo del progetto (multi folder o single folder).
    attr_accessor :type
    # @return [String] la cartella del progetto.
    attr_accessor :folder
    # @return [String] l'app corrente.
    attr_accessor :current_app
    # @return [Array<String>] le main apps del progetto.
    attr_accessor :main_apps
    # @return [Array<String>] gli engines del progetto.
    attr_accessor :engines

    def initialize(config_file)
      config = YAML.load_file(config_file).deep_symbolize_keys!
      self.name = config[:dev][:project_name]
      self.type = config[:dev][:project_type].try(:to_sym)
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
      self.engines + self.main_apps
    end

    ##
    # Cerca di determinare l'app corrente.
    #
    # @return [String] l'app corrente.
    def current_app
      @current_app || File.basename(Dir.pwd)
    end

    ##
    # Determina se l'app è valida. Prende l'app corrente se non
    # viene specificata nessuna app.
    #
    # @param [String] app_name il nome dell'app.
    #
    # @return [Boolean] se l'app è fra quelle esistenti.
    def valid_app?(app_name = self.current_app)
      if app_name.in? self.apps
        true
      else
        raise ExecutionError.new "The app '#{app_name}' is neither a main app nor an engine "\
          "within the project '#{self.name}'."
      end
    end

    ##
    # Ottiene la directory corrente nella cartella
    # dell'app specificata. Prende l'app corrente se non
    # viene specificata nessuna app.
    #
    # @param [String] app_name il nome dell'app.
    #
    # @return [nil]
    def app_folder(app_name = self.current_app)
      if self.type == :multi
        if app_name.in? self.main_apps
          "#{self.folder}/main_apps/#{app_name}"
        elsif app_name.in? self.engines
          "#{self.folder}/engines/#{app_name}"
        end
      elsif self.type == :single
        self.folder
      end
    end

    ##
    # Determina il file di versione dell'app. Prende l'app corrente se non
    # viene specificata nessuna app.
    #
    # @param [String] app_name il nome dell'app.
    #
    # @return [String] il file di versione dell'app.
    def app_version_file(app_name = self.current_app)
      Dir.glob("#{app_folder(app_name)}/lib/**/version.rb").min_by do |filename|
        filename.chars.count
      end
    end

    ##
    # Ritorna la versione dell'app. Prende l'app corrente se non
    # viene specificata nessuna app.
    #
    # @param [String] app_name il nome dell'app.
    #
    # @return [String] la versione dell'app.
    def app_version(app_name = self.current_app)
      if File.exists? app_version_file(app_name).to_s
        File.read(app_version_file(app_name))
          .match(/VERSION = '([0-9\.]+)'\n/)
          .try(:captures).try(:first)
      else
        `git tag`.split("\n").first
      end
    end

    ##
    # Alza la versione dell'app corrente a quella specificata.
    #
    # @param [String] version la versione a cui arrivare.
    #
    # @return [nil]
    def bump_app_version_to(version)
      if File.exists? self.app_version_file
        version_file = self.app_version_file
        version_content = File.read("#{version_file}")
        File.open(version_file, 'w+') do |f|
          f.puts version_content.gsub(/VERSION = '[0-9\.]+'\n/, "VERSION = '#{version}'\n")
        end
      end
    end
    
  end
end
