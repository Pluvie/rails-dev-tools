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

          apps.each do |current_app|
            @project.current_app = current_app
            if @project.valid_app?
              Dir.chdir @project.app_folder
              current_branch = `git rev-parse --abbrev-ref HEAD`
              
              print "Preparing to pull app "
              print current_app.teal
              print " on branch "
              print current_branch.teal
              puts

              print "\tPulling.. "
              remote_message = exec "git pull origin #{current_branch}"
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
