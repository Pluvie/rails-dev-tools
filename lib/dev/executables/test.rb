module Dev
  module Executables
    module Test

      ##
      # Esegue i test delle app specificate.
      # Se non viene specificato niente, esegue i test di tutte le app.
      #
      # @param [Array] apps le app per cui eseguire i test.
      #
      # @return [nil]
      def test(*apps)
        if apps.any?
          # Esegue i test per le app specificate
          tested_apps = []
          # Controlla che le app specificate siano valide
          apps.each do |app|
            @app = app.try(:to_sym)
            valid_app?
            tested_apps << @app
          end
        else
          # Esegue i test per tutte le app
          tested_apps = Dev::Executable::MAIN_APPS
        end

        tested_apps.each do |app|
          @app = app
          Dir.chdir File.join(File.expand_path('../..', Dir.pwd), folder)

          print "Eseguo test dell'app "
          print @app.to_s.teal
          puts '..'
          puts
          test_output = exec('script -q /dev/null rspec --format documentation')
          test_output = test_output[2..-1]
            .gsub("\s\s", '§§')               # Memorizza le indentazioni
            .split("\n")                      # Divide ogni riga
            .map(&:squish).join("\n\t\t")     # E ne toglie spazi extra
            .gsub('§§', "\s\s\s\s")           # Riunisce tutto preservando le indentazioni
          puts "\t\t#{test_output}"
          puts
        end
      end

    end
  end
end
