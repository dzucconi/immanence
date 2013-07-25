# coding: utf-8

lib = File.expand_path("../lib", __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "immanence/version"

Gem::Specification.new do |spec|
  spec.name          = "immanence"
  spec.version       = Immanence::VERSION
  spec.authors       = ["dzucconi"]
  spec.email         = ["mail@damonzucconi.com"]
  spec.description   = "A framework"
  spec.summary       = "A framework"
  spec.homepage      = "http://github.com/dzucconi/immanence"
  spec.license       = "CC0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.0"

  spec.add_runtime_dependency "rack", "~> 1.5.2"
  spec.add_runtime_dependency "oj", "~> 2.1.4"
end
