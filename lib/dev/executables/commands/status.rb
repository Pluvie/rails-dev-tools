module Dev
  module Executables
    module Commands
      module Status

        ##
        # Stampa lo stato dell'app specificata o di tutte le app.
        #
        # @return [nil]
        def status(app = nil)
          if app.present?
            apps = [ app ]
          else
            apps = project.apps
          end

          apps.each do |current_app|
            @project.current_app = current_app
            if @project.valid_app?
              @project.chdir_app
              current_branch = `git rev-parse --abbrev-ref HEAD`

              print "Status of app "
              puts current_app.teal
              puts

              print "\tbranch: "
              print current_branch.limegreen
              print "\tversion: "
              puts @project.app_version.try(:limegreen) || "not found".limegreen
              puts
            end
          end
        end

      end
    end
  end
end
