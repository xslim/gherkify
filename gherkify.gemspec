# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gherkify/version'

Gem::Specification.new do |gem|
  gem.name          = "gherkify"
  gem.version       = Gherkify::VERSION
  gem.authors       = ["Taras Kalapun"]
  gem.email         = ["t.kalapun@gmail.com"]
  gem.summary       = %q{Generate yUML diagrams from Gherkin Cucumber feature files}
  gem.description   = gem.summary
  gem.homepage      = "https://github.com/xslim/gherkify"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'gherkin'
  gem.add_dependency 'slop'
  # gem.add_dependency 'ruby-yuml'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'aruba'
  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'pry'
end
