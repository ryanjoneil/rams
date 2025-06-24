# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rams'
  spec.version       = '0.2.0'
  spec.authors       = ["Ryan J. O'Neil"]
  spec.email         = ['adventures-in-opt.1ba50@passmail.net']
  spec.summary       = 'Ruby Algebraic Modeling System'
  spec.description   = 'A library for solving MILPs in Ruby.'
  spec.homepage      = 'https://github.com/ryanjoneil/rams'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1.0'
end
