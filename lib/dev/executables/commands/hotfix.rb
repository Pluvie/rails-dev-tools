module Dev
  module Executables
    module Commands
      module Hotfix

        ##
        # Comandi per gestire l'apertura e la chiusura di un nuovo rilascio.
        #
        # @param [String] command il comando da eseguire.
        # @param [String] version la versione dell'hotfix.
        #
        # @return [nil]
        def hotfix(command = nil, version = nil)
          raise Dev::Executable::ExecutionError.new "Wrong command syntax: "\
            "specify whether to open or close a hotfix. "\
            "Example: dev hotfix open 1.0.0" unless command.in? [ 'open', 'close' ]
          version = version.to_s.squish

          if valid_app?
            case command
            when 'open' then hotfix_open(version)
            when 'close' then hotfix_close(version)
            end
          end
        end

        ##
        # Apre una nuova hotfix.
        #
        # @param [String] version la versione dell'hotfix.
        #
        # @return [nil]
        def hotfix_open(version)
          print "Preparing to open a new hotfix for app "
          print @project.current_app.teal
          print " with version "
          puts version.teal
          puts

          print "\tOpening.. "
          git_output = exec "git checkout -b hotfix/#{version} master"
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
          if File.exists? app_version_file
            print "\tBumping '#{app_version_file}' to #{version}.. "
            version_content = File.read("#{app_version_file}")
            File.open(app_version_file, 'w+') do |f|
              f.puts version_content.gsub(/VERSION = '[0-9\.]+'\n/, "VERSION = '#{version}'")
            end
            print "√\n".green
            puts
          end
        end

        ##
        # Chiude una hotfix esistente.
        #
        # @param [String] version la versione dell'hotfix.
        #
        # @return [nil]
        def hotfix_close(version)
          print "Preparing to close the hotfix for app "
          print @project.current_app.teal
          print " with version "
          puts version.teal
          puts

          status = `git status`
          if status.include? "Changes not staged for commit:"
            raise Dev::Executable::ExecutionError.new "Your current branch has unstaged changes. Please "\
              "commit or stash them before closing the hotfix."
          end

          branches = `git branch -a`
          unless branches.include? ("hotfix/#{version}\n")
            raise Dev::Executable::ExecutionError.new "No hotfix for version '#{version}' could be found "\
              "for this app's repository."
          end

          print "\tClosing.. "
          exec "git checkout master"
          exec "git merge --no-ff hotfix/#{version}"
          exec "git tag -a #{version} -m \"hotfix #{version}\""
          git_output = exec "git push origin master"
          if git_output.include?('fatal') or git_output.include?('rejected') or git_output.include?('error')
            print "X\n".red
            puts "\t\tSomething went wrong, take a look at the output from git:".indianred
            puts "\t\t#{git_output.split("\n").map(&:squish).join("\n\t\t")}".indianred
            puts
          else
            print "√\n".green
            puts "\t\tDone. Output from git:".cadetblue
            puts "\t\t#{git_output.split("\n").map(&:squish).join("\n\t\t")}".cadetblue

            print "\tMerging hotfix on develop.."
            exec "git checkout develop"
            exec "git merge --no-ff hotfix/#{version}"
            git_output = exec "git push origin develop"
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
        end

      end
    end
  end
end
