require 'open3'
require 'dev/project'
require 'dev/executables/commands/version'
require 'dev/executables/commands/feature'
require 'dev/executables/commands/release'
require 'dev/executables/commands/pull'
require 'dev/executables/commands/push'
require 'dev/executables/commands/test'

module Dev

  ##
  # Classe per gestire l'esecuzione del comando +dev+.
  class Executable

    ##
    # Definisce la classe per tutti gli errori interni
    # all'esecuzione.
    class ExecutionError < StandardError; end

    include Dev::Executables::Commands::Version
    include Dev::Executables::Commands::Feature
    include Dev::Executables::Commands::Release
    include Dev::Executables::Commands::Pull
    include Dev::Executables::Commands::Push
    include Dev::Executables::Commands::Test

    # @return [Dev::Executables::Project] il progetto di riferimento.
    attr_accessor :project

    ##
    # Inizializza l'eseguibile, in base al comando passato.
    #
    # @param [Array] argv gli argomenti del comando.
    def initialize(*argv)
      if argv[0].present?
        if self.respond_to?(argv[0])
          # Carica i dati del progetto
          load_project
          # Lancia il comando passato
          if self.method(argv[0]).arity.abs > 0
            self.send(argv[0], *argv[1..-1])
          else
            self.send(argv[0])
          end
        else
          raise ExecutionError.new "Command '#{argv[0]}' is not supported. Run "\
            "'dev help' for a list of available commands."
        end
      else
        raise ExecutionError.new "Missing required parameters. Run 'dev help' "\
          "for a list of available commands."
      end
    end

    ##
    # Carica i dati del progetto prendendoli dal file
    # di configurazione del file 'dev.yml'.
    #
    # @return [nil]
    def load_project
      config_file = Dir.glob("#{Dir.pwd}/**/dev.yml").first
      raise ExecutionError.new "No valid configuration files found. Searched for a file named 'dev.yml' "\
        "in folder #{Dir.pwd} and all its subdirectories." if config_file.nil?
      @project = Dev::Project.new(config_file)
    end

    ##
    # Determina se l'app è valida.
    #
    # @return [Boolean] se l'app è fra quelle esistenti.
    def valid_app?
      if @app.in? @project.apps
        true
      else
        raise ExecutionError.new "The app '#{@app}' is neither a main app nor an engine "\
          "within the project '#{@project.name}'."
      end
    end

    ##
    # Determina de l'env è valido.
    #
    # @return [Boolean] se l'env è fra quelli validi.
    def valid_env?
      unless @env.in? [ :production, :staging ]
        raise ExecutionError.new "The environment '#{@env}' is not valid. "\
          "Valid environments are 'production' or 'staging'."
      else
        true
      end
    end

    ##
    # Esegue un comando e cattura l'output ritornandolo come
    # risultato di questo metodo. Si può passare l'opzione
    # +flush+ per stampare subito l'output come se non fosse stato
    # catturato.
    #
    # @param [String] command il comando da eseguire.
    # @param [Hash] options le opzioni.
    #
    # @return [nil]
    def exec(command, options = {})
      out, err, status = Open3.capture3(command)
      command_output = [ out.presence, err.presence ].compact.join("\n")
      if options[:flush] == true
        puts command_output
      else
        command_output
      end
    end

    ##
    # Stampa i comandi possibili.
    #
    # @return [nil]
    def help
      puts
      print "Dev".green
      print " - available commands:\n"
      puts
      
      print "\tversion\t\t".limegreen 
        print "Prints current version.\n"
        puts

      print "\tfeature\t\t".limegreen
        print "Opens or closes a feature for the current app.\n"
        print "\t\t\tWarning: the app is determined from the current working directory!\n"
        print "\t\t\tExample: "
        print "dev feature open my-new-feature".springgreen
        print " (opens a new feature for the current app)"
        print ".\n"
        print "\t\t\tExample: "
        print "dev feature close my-new-feature".springgreen
        print " (closes a developed new feature for the current app)"
        print ".\n"
        puts

      print "\trelease\t\t".limegreen
        print "Opens or closes a release for the current app.\n"
        print "\t\t\tWarning: the app is determined from the current working directory!\n"
        print "\t\t\tExample: "
        print "dev release open 0.2.0".springgreen
        print " (opens a new release for the current app)"
        print ".\n"
        print "\t\t\tExample: "
        print "dev release close 0.2.0".springgreen
        print " (closes a developed new release for the current app)"
        print ".\n"
        puts

      print "\tpull\t\t".limegreen
        print "Pulls specified app's git repository, or pulls all apps if none are specified.\n"
        print "\t\t\tWarning: the pulled branch is the one the app is currently on!\n"
        print "\t\t\tExample: "
        print "dev pull [myapp]".springgreen
        print ".\n"
        puts

      print "\tpush\t\t".limegreen
        print "Commits and pushes the specified app.\n"
        print "\t\t\tWarning: the pushed branch is the one the app is currently on!\n"
        print "\t\t\tExample: "
        print "dev push myapp \"commit message\"".springgreen
        print ".\n"
        puts

      print "\ttest\t\t".limegreen
        print "Runs the app's test suite. Tests must be written with rspec.\n"
        print "\t\t\tIt is possibile to specify which app's test suite to run.\n"
        print "\t\t\tIf nothing is specified, all main app's test suites are run.\n"
        print "\t\t\tExample: "
        print "dev test mymainapp myengine".springgreen
        print " (runs tests for 'mymainapp' and 'myengine')"
        print ".\n"
        print "\t\t\tExample: "
        print "dev test".springgreen
        print " (runs tests for all main apps and engines within this project)"
        print ".\n"
        puts
    end

  end

end
