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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/HealthDataInsight/structured_store.git'
  spec.metadata['changelog_uri'] = 'https://github.com/HealthDataInsight/structured_store.git/blob/main/CHANGELOG.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 7.2.2.1'
  spec.add_dependency 'zeitwerk', '~> 2.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
