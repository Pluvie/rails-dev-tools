module Dev
  module Executables
    module Commands
      module Release

        ##
        # Comandi per gestire l'apertura e la chiusura di un nuovo rilascio.
        #
        # @param [String] command il comando da eseguire.
        # @param [String] version la versione del rilascio.
        #
        # @return [nil]
        def release(command = nil, version = nil)
          @app = File.basename Dir.pwd
          raise Dev::Executable::ExecutionError.new "Wrong command syntax: "\
            "specify whether to open or close a release. "\
            "Example: dev release open 1.0.0" unless command.in? [ 'open', 'close' ]
          version = version.to_s.squish

          if valid_app?
            case command
            when 'open' then release_open(version)
            when 'close' then release_close(version)
            end
          end
        end

        ##
        # Apre una nuova release.
        #
        # @param [String] version la versione del rilascio.
        #
        # @return [nil]
        def release_open(version)
          print "Preparing to open a new release for app "
          print @app.teal
          print " with version "
          puts version.teal
          puts

          branches = `git branch -a`
          unless branches.include? ("develop\n")
            print "\tCreating develop branch.."
            exec "git checkout -b develop"
            exec "git add ."
            exec "git commit -m \"Dev: automatically created 'develop' branch\""
            exec "git push -u origin develop"
            print "√\n".green
            puts
          end

          print "\tOpening.. "
          git_output = exec "git checkout -b release/#{version} develop"
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
          if @app.in? @project.engines
            version_file = "lib/#{@app}/version.rb"
            print "\tBumping '#{version_file}' to #{version}.. "
            version_content = File.read("#{version_file}")
            File.open(version_file, 'w+') do |f|
              f.puts version_content.gsub(/VERSION = '[0-9\.]+'\n/, "VERSION = '#{version}'")
            end
            print "√\n".green
            puts
          end
        end

        ##
        # Chiude una release esistente.
        #
        # @param [String] version la versione del rilascio.
        #
        # @return [nil]
        def release_close(version)
          print "Preparing to close the release for app "
          print @app.teal
          print " with version "
          puts version.teal
          puts

          status = `git status`
          if status.include? "Changes not staged for commit:"
            raise Dev::Executable::ExecutionError.new "Your current branch has unstaged changes. Please "\
              "commit or stash them before closing the release."
          end

          branches = `git branch -a`
          unless branches.include? ("release/#{version}\n")
            raise Dev::Executable::ExecutionError.new "No release for version '#{version}' could be found "\
              "for this app's repository."
          end

          print "\tClosing.. "
          exec "git checkout master"
          exec "git merge --no-ff release/#{version}"
          exec "git tag -a #{version} -m \"release #{version}\""
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
            puts
          end
        end

      end
    end
  end
end
