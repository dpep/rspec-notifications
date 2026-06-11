require_relative "lib/rspec/notifications/version"
package = RSpec::Notifications
package_name = "rspec-notifications"

Gem::Specification.new do |s|
  s.authors     = ["Daniel Pepper"]
  s.description = "RSpec matchers for ActiveSupport::Notifications"
  s.files       = `git ls-files * ':!:spec'`.split("\n")
  s.homepage    = "https://github.com/dpep/#{package_name}"
  s.license     = "MIT"
  s.name        = package_name
  s.summary     = package.to_s
  s.version     = package.const_get "VERSION"

  s.required_ruby_version = ">= 3.2"

  s.add_dependency "activesupport", ">= 7"
  s.add_dependency "rspec-expectations", ">= 3"

  s.add_development_dependency "debug"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
end
