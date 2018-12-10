module Dev
  module Executables
    module Commands
      module Version

        ##
        # Stampa la versione corrente di H-Benchmark.
        #
        # @return [nil]
        def version
          puts
          print "Dev".green
          print " versione: "
          puts "#{Dev::VERSION}.".limegreen
          puts
        end

      end
    end
  end
end
