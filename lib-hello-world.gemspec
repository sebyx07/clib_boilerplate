# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'clib-hello-world'
  spec.version       = '0.1.0'
  spec.authors       = ['sebi']
  spec.email         = ['sebastian.buza1@gmail.com']

  spec.summary       = 'A simple Hello World C library'
  spec.description   = 'Example C library using the clib packaging system'
  spec.homepage      = 'https://github.com/sebi/clib-hello-world'
  spec.license       = 'MIT'

  spec.files         = Dir['{ext,include}/**/*', 'LICENSE', 'README.md']

  spec.add_development_dependency 'rake', '~> 13.0'
end
