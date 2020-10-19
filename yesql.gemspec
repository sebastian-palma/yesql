# frozen_string_literal: true

require_relative 'lib/yesql/version'

Gem::Specification.new do |spec|
  spec.name = 'yesql'
  spec.version = YeSQL::VERSION
  spec.authors = ['Sebastián Palma']
  spec.email = ['vnhnhm.github@gmail.com']
  spec.summary = 'Ruby library to use SQL'
  spec.description = 'SQL "raw" for Rails projects'
  spec.homepage = 'https://github.com/sebastian-palma/yesql'
  spec.license = 'MIT'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/sebastian-palma/yesql'
  spec.metadata['changelog_uri'] = 'https://github.com/sebastian-palma/yesql'
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'rails', '>= 5.0'
  spec.add_development_dependency 'mysql2', '~> 0.5.3'
  spec.add_development_dependency 'pg', '>= 0.18'
  spec.add_development_dependency 'pry', '~> 0.13.1'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
end
