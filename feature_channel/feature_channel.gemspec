# frozen_string_literal: true

require_relative 'lib/feature_channel/version'

Gem::Specification.new do |spec|
  spec.name          = 'feature_channel'
  spec.version       = FeatureChannel::VERSION
  spec.authors       = ['Daniel Vinciguerra']
  spec.email         = ['daniel.vinciguerra@bivee.com.br']

  spec.summary       = 'Connect your features and services'
  spec.description   = '
    FeatureChannel is a generic componnet to connect your features and services using diferent strategies
  '
  spec.homepage      = 'https://github.com/dvinciguerra'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'msgpack', '~> 1.3', '>= 1.3.3'
end
