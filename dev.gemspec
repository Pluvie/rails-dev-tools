$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "dev/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name           = "rails-dev-tools"
  spec.version        = Dev::VERSION
  spec.authors        = ["Francesco Ballardin"]
  spec.email          = ["francesco.ballardin@gmail.com"]
  spec.homepage       = "https://github.com/Pluvie/rails-dev-tools"
  spec.summary        = %q{A set of tools to help development on complex Ruby on Rails projects with many main apps and engines.}
  spec.description    = %q{A set of tools to help development on complex Ruby on Rails projects with many main apps and engines.}
  spec.license        = "MIT"

  spec.files          = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.executables    = [ "dev" ]

  spec.add_dependency "rails", "~> 5.2.2"
  spec.add_dependency "rainbow", "~> 2.1"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 3.8"
  spec.add_development_dependency "sqlite3", "~> 1.3"
end
