module Dev
  module Executables
    module Commands
      module Feature

        ##
        # Comandi per gestire l'apertura e la chiusura di una nuova feature.
        #
        # @param [String] command il comando da eseguire.
        # @param [String] name il nome della feature.
        #
        # @return [nil]
        def feature(command = nil, name = nil)
          @app = File.basename Dir.pwd
          raise Dev::Executable::ExecutionError.new "Wrong command syntax: "\
            "specify whether to open or close a feature. "\
            "Example: dev feature open my-new-feature" unless command.in? [ 'open', 'close' ]
          name = name.to_s.squish

          if valid_app?
            case command
            when 'open' then feature_open(name)
            when 'close' then feature_close(name)
            end
          end
        end

        ##
        # Apre una nuova feature.
        #
        # @param [String] name il nome della feature.
        #
        # @return [nil]
        def feature_open(name)
          print "Preparing to open a new feature for app "
          print @app.teal
          print " named "
          print name.teal
          puts

          branches = `git branch -a`
          unless branches.include? ("develop\n")
            print "\tCreating develop branch.."
            exec "git checkout -b develop"
            exec "git add ."
            exec "git commit -m \"Dev: automatically created 'develop' branch\""
            exec "git push -u origin develop"
          end

          print "\tOpening.. "
          git_output = exec "git checkout -b feature/#{name} develop"
          if git_output.include?('fatal') or git_output.include?('rejected') or git_output.include?('error')
            print "X\n".red
            puts "\t\tSomething went wrong, take a look at the output from git:".indianred
            puts "\t\t#{git_output.split("\n").map(&:squish).join("\n\t\t")}".indianred
            puts
          else
            print "√\n".green
            puts "\t\tDone. Output from git:".cadetblue
            puts "\t\t#{git_output.split("\n").map(&:squish).join("\n\t\t")}".cadetblue
            puts
          end
        end

        ##
        # Chiude una feature esistente.
        #
        # @param [String] name il nome della feature.
        #
        # @return [nil]
        def feature_close(name)
        end

      end
    end
  end
end
