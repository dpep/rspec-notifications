require_relative "lib/rspec/notifications/version"

Gem::Specification.new do |s|
  s.name        = "rspec-notifications"
  s.version     = RSpec::Notifications::VERSION
  s.authors     = ["Daniel Pepper"]
  s.description = "RSpec matchers for ActiveSupport::Notifications"
  s.files       = `git ls-files * ':!:spec'`.split("\n")
  s.homepage    = "https://github.com/dpep/rspec-notifications"
  s.license     = "MIT"
  s.summary     = "RSpec::Notifications"

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "activesupport", ">= 7"
  s.add_dependency "rspec-expectations", ">= 3"

  s.add_development_dependency "debug"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
end
