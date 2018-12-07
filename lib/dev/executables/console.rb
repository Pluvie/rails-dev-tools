module Dev
  module Executables
    module Console

      ##
      # Esegue la console dell'app nell'ambiente specificato.
      #
      # @param [String] app l'app per cui eseguire la console.
      # @param [String] env l'ambiente Rails su cui eseguire la console.
      #
      # @return [nil]
      def console(app = nil, env = nil)
        if app.present? and env.present?
          @app = app.try(:to_sym)
          @env = env.try(:to_sym)
          
          if valid_app? and valid_env?
            Dir.chdir File.join(File.expand_path('../..', Dir.pwd), folder)
            
            print "Eseguo console dell'app "
            print @app.to_s.teal
            print " nell'ambiente di "
            print @env.to_s.teal
            puts
            puts

            puts "\tCollegamento alla console con mina.. "
            puts
            Kernel.exec("mina #{@env} console")
          end
        else
          raise Dev::Executable::ExecutionError.new "Sintassi del comando errata: "\
            "specificare un'app e l'ambiente. Ad esempio: hb console app production."
        end
      end

    end
  end
end
