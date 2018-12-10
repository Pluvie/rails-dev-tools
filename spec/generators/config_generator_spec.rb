require 'generators/dev/config_generator'

RSpec.describe Dev::Generators::ConfigGenerator do

  it "generates a configuration file for the main app" do

    remove_file 'test/dummy/dev.yml'
    Dev::Generators::ConfigGenerator.start([], destination_root: 'test/dummy')
    expect(File).to exist('test/dummy/dev.yml')
    
  end

end
