# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'canvas_data_client/version'

Gem::Specification.new do |spec|
  spec.name          = "canvas_data_client"
  spec.version       = CanvasDataClient::VERSION
  spec.authors       = ["Ben Y"]
  spec.email         = ["jyf0000@gmail.com"]

  spec.summary       = "Wraps the endpoints provided by Canvas Data."
  spec.homepage      = "https://github.com/ben-y/canvas_data_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end