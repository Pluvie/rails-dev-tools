module Dev
  module Executables
    module Pull

      ##
      # Esegue il commit e il push del repository dell'app specificata.
      #
      # @param [String] app l'app per cui il push delle modifiche.
      #
      # @return [nil]
      def pull(app = nil)
        if app.present?
          apps = [ app ]
        else
          apps = Dev::Executable::ENGINES + Dev::Executable::MAIN_APPS
        end

        apps.each do |app|
          @app = app.try(:to_sym)
          
          if valid_app?
            Dir.chdir File.join(File.expand_path('../..', Dir.pwd), folder)
            
            print "Eseguo pull dell'app "
            print @app.to_s.teal
            print " nel branch "
            print `git rev-parse --abbrev-ref HEAD`.teal
            puts

            print "\tEseguo pull.. "
            remote_message = exec 'git pull'
            if remote_message.include?('fatal') or remote_message.include?('rejected') or remote_message.include?('error')
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
        end
      end

    end
  end
end
