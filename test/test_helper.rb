if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    # Set root to the engine directory (where gemspec is located)
    root File.expand_path('..', File.dirname(__FILE__))

    add_group "Models", "app/models"
    # add_group "Helpers", "app/helpers"
    add_group "Libraries", "lib/"
    add_group 'Validators', 'app/validators'

    track_files "{app,lib}/**/*.rb"
    track_files "test/dummy/{app,lib}/**/*.rb"

    # Filter test directories
    add_filter %r{^/test/(?!dummy/)}
    add_filter %r{^/test/.+_test\.rb}
    add_filter %r{^/test/dummy/(config|db|test)/}
    add_filter { |source_file| source_file.lines.count < 8 }
  end

  puts 'Required SimpleCov'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
require 'rails/test_help'
require 'mocha/minitest'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path('fixtures', __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = "#{File.expand_path('fixtures', __dir__)}/files"
  ActiveSupport::TestCase.fixtures :all
end

# Auto-require dummy app tests so they're discovered by `bin/rails test`
Dir[File.expand_path('dummy/test/**/*_test.rb', __dir__)].each { |file| require file }
