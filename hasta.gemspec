# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hasta/version'

Gem::Specification.new do |spec|
  spec.name          = "hasta"
  spec.version       = Hasta::VERSION
  spec.authors       = ["danhodge"]
  spec.email         = ["dan@swipely.com"]
  spec.summary       = %q{HAdoop Streaming Test hArness}
  spec.description   = %q{Harness for locally testing streaming Hadoop jobs written in Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fog"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "cane"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", '~> 2.13.0'
end
