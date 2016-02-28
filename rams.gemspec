# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rams'
  spec.version       = '0.1'
  spec.authors       = ["Ryan J. O'Neil"]
  spec.email         = ['ryanjoneil@gmail.com']
  spec.summary       = 'Ruby Algebraic Modeling System'
  spec.description   = 'todo'
  spec.homepage      = 'todo'
  spec.license       = 'MIT'

  spec.files         = ['lib/rams.rb']
  spec.test_files    = ['tests/test_rams.rb']
  spec.require_paths = ['lib']
end
