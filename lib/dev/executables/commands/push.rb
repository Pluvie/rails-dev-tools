module Dev
  module Executables
    module Commands
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
            @app = app
            if valid_app?
              @project.chdir_app(@app)
              current_branch = `git rev-parse --abbrev-ref HEAD`
              
              print "Preparing to push app "
              print @app.teal
              print " on branch "
              print current_branch.teal
              puts
              
              print "\tRunning bundler.. "
              exec 'bundle install'
              print "√\n".green

              print "\tCommitting.. "
              exec 'git add .'
              exec "git commit -m \"#{commit_message}\""
              print "√\n".green

              print "\tPushing.. "
              remote_message = exec "git push origin #{current_branch}"
              if remote_message.include?('fatal') or remote_message.include?('rejected')
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
          else
            raise Dev::Executable::ExecutionError.new "Wrong command syntax: "\
              "specify an app and a commit message. "\
              "Example: dev push app \"commit message\"."
          end
        end

      end
    end
  end
end
