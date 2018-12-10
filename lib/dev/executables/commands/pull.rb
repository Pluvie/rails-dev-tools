module Dev
  module Executables
    module Commands
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
            apps = project.apps
          end

          apps.each do |app|
            @app = app
            if valid_app?
              @project.chdir_app(@app)
              
              print "Preparing to pull app "
              print @app.teal
              print " on branch "
              print `git rev-parse --abbrev-ref HEAD`.teal
              puts

              print "\tPulling.. "
              remote_message = exec 'git pull'
              if remote_message.include?('fatal') or remote_message.include?('rejected') or remote_message.include?('error')
                print "X\n".red
                puts "\t\tSomething went wrong, take a look at the output from git remote:".indianred
                puts "\t\t#{remote_message.split("\n").map(&:squish).join("\n\t\t")}".indianred
                puts
              else
                print "√\n".green
                puts "\t\tDone. Output from git remote:".cadetblue
                puts "\t\t#{remote_message.split("\n").map(&:squish).join("\n\t\t")}".cadetblue
                puts
              end
            end
          end
        end

      end
    end
  end
end
