require 'generators/dev/config_generator'

RSpec.describe Generators::Dev::ConfigGenerator do

  it "generates a configuration file for the main app" do
    
    Generators::Dev::ConfigGenerator.start([], )
    
  end

end
