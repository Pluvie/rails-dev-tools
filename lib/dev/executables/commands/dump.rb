module Dev
  module Executables
    module Commands
      module Dump

        ##
        # Esegue il dump del database dall'ambiente specificato.
        #
        # @param [String] source l'ambiente origine.
        #
        # @return [nil]
        def dump(source_env = nil, except = nil, *excluded_collections)
          @env = source_env.try(:to_sym)
          if valid_env?
            if except.present? and except != 'except'
              raise Dev::Executable::ExecutionError.new "Digitare 'except' "\
                "invece di '#{except}' se si vogliono escludere delle collezioni dal dump."
            else
              print "Eseguo dump del database dall'ambiente di "
              print @env.to_s.teal
              puts
              puts

              require 'net/ssh'
              dump_file = File.join('/tmp', "dump_hbenchmark_#{@source_env}_#{Time.current.strftime('%Y%m%d_%H%M')}.gz")
              dump_command = "mongodump --db hbenchmark --archive=#{dump_file} --gzip"
              if excluded_collections.any?
                excluded_collections.each do |excluded_collection|
                  dump_command += " --excludeCollection #{excluded_collection}"
                end
              end

              # Esegue dump su macchina remota
              print "\tEseguo dump su macchina remota.. "
                Net::SSH.start(server, 'azureuser', forward_agent: true) do |ssh|
                  ssh.exec!(dump_command)
                end
              print "√\n".green

              # Copia dump in locale
              print "\tCopio dump in locale.. "
                exec "rsync -avz --remove-source-files azureuser@#{server}:#{dump_file} #{dump_file}"
              print "√\n".green

              # Esegue restore
              print "\tEseguo restore.. "
                exec %{mongo --eval "conn = new Mongo(); db = conn.getDB('hbenchmark'); db.dropDatabase(); quit();"}
                exec "mongorestore --gzip --archive=#{dump_file}"
                exec "rm -rf #{dump_file}"
              print "√\n".green

              puts
            end
          end
        end

      end
    end
  end
end
