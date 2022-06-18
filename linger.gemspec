require_relative "lib/linger/version"

Gem::Specification.new do |s|
  s.name = "linger"
  s.version = Linger::VERSION
  s.authors = ["leastbad"]
  s.email = "hello@leastbad.com"
  s.summary = "Provide Devise-style authentication helpers for StimulusReflex"
  s.homepage = "https://github.com/leastbad/linger"
  s.license = "MIT"

  s.required_ruby_version = ">= 2.7.0"
  s.add_dependency "activesupport", ">= 6.0.0"
  s.add_dependency "redis", "~> 4.2"
  s.add_development_dependency "rails", ">= 6.0.0"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "README.md"]
end
