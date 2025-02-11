# frozen_string_literal: true

require 'yaml'

config = YAML.load_file(File.join(__dir__, '.clib.yml'))

Gem::Specification.new do |spec|
  spec.name          = 'clib-hello-world'
  spec.version       = config['version']
  spec.authors       = ['sebi']
  spec.email         = ['sebastian.buza1@gmail.com']

  spec.summary       = 'A simple Hello World C library'
  spec.description   = 'Example C library using the clib packaging system'
  spec.homepage      = 'https://github.com/sebi/clib-hello-world'
  spec.license       = 'MIT'

  spec.files         = Dir['{ext,include}/**/*', 'LICENSE', 'README.md']

  spec.required_ruby_version = '>= 3.0'

  if config['dependencies']
    config['dependencies'].each do |lib, version|
      spec.add_runtime_dependency lib, version
    end
  end

  spec.add_development_dependency 'rake', '~> 13.0'
end
