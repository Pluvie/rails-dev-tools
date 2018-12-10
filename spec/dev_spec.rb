RSpec.describe Dev do
  
  it "has a version number" do
    expect(Dev::VERSION).not_to be nil
  end

  it "responds to version command" do
    exec = Dev::Executable.new('version')
    expect(exec.error).to be nil
  end

  it "responds to status command" do
    exec = Dev::Executable.new('status')
    expect(exec.error).to be nil
  end

end
