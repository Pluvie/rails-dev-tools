require 'open3'
require 'dev/executables/version'
require 'dev/executables/setup'
require 'dev/executables/dump'
require 'dev/executables/pull'
require 'dev/executables/push'
require 'dev/executables/deploy'
require 'dev/executables/console'
# require 'dev/executables/logs'
# require 'dev/executables/open'
require 'dev/executables/test'

module Dev

  ##
  # Classe per gestire l'esecuzione del comando +dev+.
  class Executable

    ##
    # Definisce la classe per tutti gli errori interni
    # all'esecuzione.
    class ExecutionError < StandardError; end

    include Dev::Executables::Version
    include Dev::Executables::Setup
    include Dev::Executables::Dump
    include Dev::Executables::Pull
    include Dev::Executables::Push
    include Dev::Executables::Deploy
    include Dev::Executables::Console
    # include Dev::Executables::Logs
    # include Dev::Executables::Dump
    # include Dev::Executables::Open
    include Dev::Executables::Test

    ##
    # Le main app di H-Benchmark.
    MAIN_APPS = [ :hstaff, :portal, :worker, :linkup, :api, :account ]

    ##
    # I motori di H-Benchmark.
    ENGINES = [ :master, :reporting, :ingestion, :subscription ]

    # @return [String] l'app di riferimento, presa dalle MAIN_APPS o dagli ENGINES.
    attr_accessor :app

    ##
    # Inizializza l'eseguibile, in base al comando passato.
    #
    # @param [Array] argv gli argomenti del comando.
    def initialize(*argv)
      if argv[0].present?
        if self.respond_to?(argv[0])
          if self.method(argv[0]).arity.abs > 0
            self.send(argv[0], *argv[1..-1])
          else
            self.send(argv[0])
          end
        else
          raise ExecutionError.new "Il comando '#{argv[0]}' non è supportato. Eseguire "\
            "'hb help' per un elenco di comandi disponibili."
        end
      else
        raise ExecutionError.new "Passare un'opzione al comando. Eseguire 'hb help' "\
          "per un elenco di comandi disponibili."
      end
    end

    ##
    # Determina se l'app è valida.
    #
    # @return [Boolean] se l'app è fra quelle esistenti.
    def valid_app?
      if @app.in?(MAIN_APPS) or @app.in?(ENGINES)
        true
      else
        raise ExecutionError.new "L'app '#{@app}' non fa parte di nessuna main_app o engine."
      end
    end

    ##
    # Determina de l'env è valido.
    #
    # @return [Boolean] se l'env è fra quelli validi.
    def valid_env?
      unless @env.in? [ :production, :staging ]
        raise ExecutionError.new "L'ambiente '#{@env}' non è valido. "\
          "Gli ambienti validi sono 'production' o 'staging'."
      else
        true
      end
    end

    ##
    # Determina la cartella padre dell'app in esecuzione.
    #
    # @return [String] la cartella.
    def folder
      if @app.in? MAIN_APPS
        "main_apps/#{@app}"
      elsif @app.in? ENGINES
        "engines/hbenchmark-#{@app}"
      else
        raise ExecutionError.new "L'app '#{@app}' non fa parte di nessuna main_app o engine."
      end
    end

    ##
    # Determina il server dell'env corrente.
    #
    # @return [String] il server.
    def server
      case @env
      when :production
        'hbmongo'
      when :staging
        'hbstaging'
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
      print "H-Benchmark".aqua
      print " - comandi disponibili:\n"
      puts
      
      print "\tversion\t\t".magenta 
        print "Stampa la versione corrente.\n"
        puts
      
      print "\tsetup\t\t".magenta
        print "Esegue il setup per iniziare a sviluppare sul progetto.\n"
        print "\t\t\tDeve essere lanciato su una cartella vuota.\n"
        puts

      print "\tdump\t\t".magenta
        print "Esegue il dump del database dall'ambiente origine specificato.\n"
        print "\t\t\tÈ possibile passare una lista di collezioni con il parametro except,\n"
        print "\t\t\tper escludere queste collezioni dal dump.\n"
        print "\t\t\tEsempio: "
        print "hb dump production [except daily_data reservations ..]".hotpink
        print ".\n"
        puts

      print "\tpull\t\t".magenta
        print "Esegue il pull dell'app specificata, o di tutte le app se non ne viene specificata una.\n"
        print "\t\t\tAttenzione: il pull viene eseguito sul branch in cui si trova attualmente l'app!\n"
        print "\t\t\tEsempio: "
        print "hb pull [hstaff]".hotpink
        print ".\n"
        puts
      
      print "\tpush\t\t".magenta
        print "Esegue il commit e il push dell'app specificata.\n"
        print "\t\t\tAttenzione: il push viene eseguito sul branch in cui si trova attualmente l'app!\n"
        print "\t\t\tEsempio: "
        print "hb push hstaff \"messaggio di commit\"".hotpink
        print ".\n"
        puts

      print "\tdeploy\t\t".magenta
        print "Esegue il deploy dell'app specificata nell'ambiente specificato.\n"
        print "\t\t\tIl deploy viene eseguito con mina.\n"
        print "\t\t\tEsempio: "
        print "hb deploy hstaff production".hotpink
        print ".\n"
        puts

      print "\tconsole\t\t".magenta
        print "Si collega alla console dell'app specificata nell'ambiente specificato.\n"
        print "\t\t\tLa console viene eseguita con mina.\n"
        print "\t\t\tEsempio: "
        print "hb console hstaff production".hotpink
        print ".\n"
        puts

      print "\ttest\t\t".magenta
        print "Esegue i test dell'app. I test vengono eseguiti con il comando rspec.\n"
        print "\t\t\tE' possibile specificare per quali app eseguire i test.\n"
        print "\t\t\tSe non viene specificato niente, vengono eseguiti i test per tutte le app.\n"
        print "\t\t\tEsempio: "
        print "hb test hstaff master".hotpink
        print ".\n"
        puts
    end

  end

end
