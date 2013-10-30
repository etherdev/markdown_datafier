# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'markdown_datafier/version'

Gem::Specification.new do |spec|
  spec.name          = "markdown_datafier"
  spec.version       = MarkdownDatafier::VERSION
  spec.authors       = ["J. Ryan Williams"]
  spec.email         = ["ryan@websuasion.com"]
  spec.description   = %q{API data structure generated from Markdown files}
  spec.summary       = %q{Reads a structure of Markdown files parses their metadata and outputs to a ruby hash or array of hashes. Easy to plug into your own API endpoints.}
  spec.homepage      = "https://github.com/etherdev/markdown_datafier"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "redcarpet"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.11"
end
