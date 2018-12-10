require 'rainbow'

require 'dev/executable'
require 'dev/rainbow'
require 'dev/version'

module Dev
  
  # Carica il file rainbow.rb per stampare a colori.
  load "#{File.expand_path('..', __dir__)}/lib/dev/rainbow.rb"

end
