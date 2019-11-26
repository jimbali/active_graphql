# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_graphql/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_graphql'
  spec.version       = ActiveGraphql::VERSION
  spec.authors       = ['Jim Bailey', 'Charlie Campbell']
  spec.email         = ['bailey.jim@outlook.com']

  spec.summary       = 'ActiveRecord-style models for GraphQL APIs'
  spec.homepage      = 'https://github.com/jimbali/active_graphql'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] =
    'https://github.com/jimbali/active_graphql'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # nto git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '~> 11.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.76'

  spec.add_runtime_dependency 'graphlient', '~> 0.3.7'
  spec.add_runtime_dependency 'activemodel', ['>= 4.2.10', '< 7']
  spec.add_runtime_dependency 'activesupport', ['>= 4.2.10', '< 7']
end
