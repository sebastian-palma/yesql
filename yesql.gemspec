require_relative 'lib/yesql/version'

Gem::Specification.new do |spec|
  spec.name          = "yesql"
  spec.version       = Yesql::VERSION
  spec.authors       = ["Sebastián Palma"]
  spec.email         = ["vnhnhm.github@gmail.com"]

  spec.summary       = "krisajenkins/yesql like Ruby gem"
  spec.description   = "SQL 'raw' for Rails projects"
  spec.homepage      = "https://github.com/sebastian-palma/yesql"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sebastian-palma/yesql"
  spec.metadata["changelog_uri"] = "https://github.com/sebastian-palma/yesql"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
