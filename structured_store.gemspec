require_relative 'lib/structured_store/version'

Gem::Specification.new do |spec|
  spec.name        = 'structured_store'
  spec.version     = StructuredStore::VERSION
  spec.authors     = ['Tim Gentry']
  spec.email       = ['52189+timgentry@users.noreply.github.com']
  spec.homepage    = 'https://github.com/HealthDataInsight/structured_store'
  spec.summary     = 'Store JSON structured using versioned JSON Schemas.'
  spec.description = 'StructuredStore is a gem for managing JSON data with versioned schemas.'
  spec.license     = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/HealthDataInsight/structured_store.git'
  spec.metadata['changelog_uri'] = 'https://github.com/HealthDataInsight/structured_store.git/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.required_ruby_version = '>= 3.1.0'

  spec.add_dependency 'json_schemer', '~> 2.4'
  spec.add_dependency 'rails', '>= 7.0'
  spec.add_dependency 'zeitwerk', '~> 2.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
