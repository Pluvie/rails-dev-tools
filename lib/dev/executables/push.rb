module Dev
  module Executables
    module Push

      ##
      # Esegue il commit e il push del repository dell'app specificata.
      #
      # @param [String] app l'app per cui il push delle modifiche.
      # @param [String] commit_message il messaggio di commit.
      #
      # @return [nil]
      def push(app = nil, commit_message = nil)
        if app.present? and commit_message.present?
          @app = app.try(:to_sym)
          
          if valid_app?
            Dir.chdir File.join(File.expand_path('../..', Dir.pwd), folder)
            
            print "Eseguo push dell'app "
            print @app.to_s.teal
            print " nel branch "
            print `git rev-parse --abbrev-ref HEAD`.teal
            puts
            
            print "\tAggiorno bundler.. "
            exec 'bundle install'
            print "√\n".green

            print "\tEseguo commit.. "
            exec 'git add .'
            exec "git commit -m \"#{commit_message}\""
            sleep 1
            print "√\n".green

            print "\tEseguo push.. "
            remote_message = exec 'git push'
            if remote_message.include?('fatal') or remote_message.include?('rejected')
              print "X\n".red
              puts "\t\tSi sono verificati degli errori, ecco i messaggi dal git remote:".indianred
              puts "\t\t#{remote_message.split("\n").map(&:squish).join("\n\t\t")}".indianred
              puts
            else
              print "√\n".green
              puts "\t\tMessaggi dal git remote:".cadetblue
              puts "\t\t#{remote_message.split("\n").map(&:squish).join("\n\t\t")}".cadetblue
              puts
            end
          end
        else
          raise Dev::Executable::ExecutionError.new "Sintassi del comando errata: "\
            "specificare un'app e un messaggio di commit. "\
            "Ad esempio: hb push app \"messaggio commit\"."
        end
      end

    end
  end
end
