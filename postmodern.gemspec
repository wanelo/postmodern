# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postmodern/version'

Gem::Specification.new do |spec|
  spec.name          = "postmodern"
  spec.version       = Postmodern::VERSION
  spec.authors       = ["Eric Saxby"]
  spec.email         = ["sax@livinginthepast.org"]
  spec.summary       = %q{Tools for managing PostgreSQL}
  spec.description   = %q{Tools for managing PostgreSQL}
  spec.homepage      = "https://github.com/wanelo/postmodern"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "pg"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
