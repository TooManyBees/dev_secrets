$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dev_secrets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dev_secrets"
  s.version     = DevSecrets::VERSION
  s.authors     = ["Jesse Kipp"]
  s.email       = ["jesse@toomanybees.com"]
  s.homepage    = "https://github.com/TooManyBees/dev_secrets"
  s.summary     = "Rails 5.1 encrypted secrets in dev"
  s.description = <<-DESC
Commit multiple encrypted secrets files and decrypt only the one
appropriate for the current environment.
  DESC
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.0"
end
