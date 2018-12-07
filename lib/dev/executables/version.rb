module Dev
  module Executables
    module Version

      ##
      # Stampa la versione corrente di H-Benchmark.
      #
      # @return [nil]
      def version
        puts
        puts "H-Benchmark versione: #{Dev::VERSION}.".aqua
        puts
      end

    end
  end
end
