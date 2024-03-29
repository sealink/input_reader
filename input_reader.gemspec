# -*- encoding: utf-8 -*-
require File.expand_path('../lib/input_reader/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alessandro Berardi, Michael Noack"]
  gem.email         = ["support@travellink.com.au"]
  gem.description   = %q{Command line helpers to read input of various types, confirm, etc.}
  gem.summary       = %q{Command line helpers to read input, etc.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "input_reader"
  gem.require_paths = ["lib"]
  gem.version       = InputReader::VERSION
  gem.required_ruby_version = '>= 3.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'coverage-kit'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'pry-byebug'
end
