# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lightspeed/version'

Gem::Specification.new do |spec|
  spec.name          = "lightspeed"
  spec.version       = Lightspeed::VERSION
  spec.authors       = ["Adam Sharp"]
  spec.email         = ["adsharp@me.com"]
  spec.summary       = %q{A lightweight build system for Swift.}
  spec.homepage      = "https://github.com/sharplet/lightspeed"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"

  spec.add_development_dependency "bundler", "~> 1.6"
end
