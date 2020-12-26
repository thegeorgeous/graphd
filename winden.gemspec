# frozen_string_literal: true

require_relative 'lib/winden/version'

Gem::Specification.new do |spec|
  spec.name          = 'winden'
  spec.version       = Winden::VERSION
  spec.authors       = ['George Thomas']
  spec.email         = ['iamgeorgethomas@gmail.com']

  spec.summary       = 'Ruby client for DGraph'
  spec.homepage      = 'http://thegeorgeous.com/winden'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'http://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'http://rubygems.org/winden'
  spec.metadata['changelog_uri'] = 'http://github.com/thegeorgeous/winden'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
