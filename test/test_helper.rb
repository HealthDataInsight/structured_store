if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
  puts 'Required SimpleCov'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
require 'rails/test_help'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path('fixtures', __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = "#{File.expand_path('fixtures', __dir__)}/files"
  ActiveSupport::TestCase.fixtures :all
end

# Auto-require dummy app tests so they're discovered by `bin/rails test`
Dir[File.expand_path('dummy/test/**/*_test.rb', __dir__)].each { |file| require file }
