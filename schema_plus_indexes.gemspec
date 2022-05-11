# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schema_plus/indexes/version'

Gem::Specification.new do |gem|
  gem.name          = "schema_plus_indexes"
  gem.version       = SchemaPlus::Indexes::VERSION
  gem.authors       = ["ronen barzel"]
  gem.email         = ["ronen@barzel.org"]
  gem.summary       = %q{Adds shorthands and conveniences to ActiveRecord's handling of indexes}
  gem.homepage      = "https://github.com/SchemaPlus/schema_plus_indexes"
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.5.0"

  gem.add_dependency "activerecord", ">= 5.2", "< 7.1"
  gem.add_dependency "schema_plus_core", "~> 3.1.0.beta.1"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake", "~> 13.0"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "schema_dev", "~> 4.2.beta.1"
end
