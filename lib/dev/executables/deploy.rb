module Dev
  module Executables
    module Deploy

      ##
      # Esegue il deploy dell'app nell'ambiente specificato.
      #
      # @param [String] app l'app per cui eseguire il deploy.
      # @param [String] env l'ambiente Rails verso cui eseguire il deploy.
      #
      # @return [nil]
      def deploy(app = nil, env = nil)
        if app.present? and env.present?
          @app = app.try(:to_sym)
          @env = env.try(:to_sym)
          
          if valid_app? and valid_env?
            Dir.chdir File.join(File.expand_path('../..', Dir.pwd), folder)
            
            print "Eseguo deploy dell'app "
            print @app.to_s.teal
            print " nell'ambiente di "
            print @env.to_s.teal
            puts
            puts

            puts "\tInizio deploy con mina.. "
            puts
            Kernel.exec("mina #{@env} deploy")
          end
        else
          raise Dev::Executable::ExecutionError.new "Sintassi del comando errata: "\
            "specificare un'app e l'ambiente di deploy. "\
            "Ad esempio: hb deploy app production."
        end
      end

    end
  end
end
