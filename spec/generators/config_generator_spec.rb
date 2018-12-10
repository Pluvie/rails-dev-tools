require 'generators/dev/config_generator'

RSpec.describe Generators::Dev::ConfigGenerator do

  it "generates a configuration file for the main app" do

    remove_file 'test/dummy/dev.yml'
    Generators::Dev::ConfigGenerator.start([], destination_root: 'test/dummy')
    expect(File).to exist('test/dummy/dev.yml')
    
  end

end
