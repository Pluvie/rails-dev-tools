module Dev
  module Executables
    module Setup

      ##
      # Esegue il setup per iniziare a sviluppare su H-Benchmark.
      # Il setup crea le cartelle necessarie, clonando i repository,
      # e imposta tutti gli override locali del bundler.
      #
      # @return [nil]
      def setup
        local_dir = Dir.pwd
        if Dir.empty?(local_dir)
          # Crea engines
          puts "Creo engines.."
          Dir.mkdir('engines')
          Dev::Executable::ENGINES.each do |engine|
            print "\t#{engine}.. "
            exec "git clone git@git.develondigital.com:hbenchmark/engines/#{engine}.git engines/hbenchmark-#{engine}"
            print "√\n".green
          end

          # Crea cartella etl
          Dir.mkdir('etl')

          # Crea main_apps
          puts "Creo main_apps.."
          Dir.mkdir('main_apps')
          Dev::Executable::MAIN_APPS.each do |main_app|
            print "\t#{main_app}.. "
            exec "git clone git@git.develondigital.com:hbenchmark/#{main_app}.git main_apps/#{main_app}"
            exec "ln -s etl main_apps/#{main_app}" if main_app.in? [ :hstaff, :portal ]
            exec "echo 'd3abe555f4b3e5f3f7b35fb8bd3f0c05' > main_apps/#{main_app}/config/master.key"
            # Imposta override locali sugli engine
            Dev::Executable::ENGINES.each do |engine|
              exec "cd #{local_dir}/main_apps/#{main_app} && bundle config --local local.hbenchmark-#{engine} ../../engines/hbenchmark-#{engine}"
            end
            print "√\n".green
          end
        else
          raise Dev::Executable::ExecutionError.new "Non è possibile eseguire il setup: "\
            "la cartella #{local_dir} non è vuota."
        end
      end

    end
  end
end
