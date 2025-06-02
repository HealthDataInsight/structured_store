require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

require "bundler/gem_tasks"

# Running tests via rail will ensure that the dummy app tests are run
namespace :test do
  task :via_rails do
    system('bin/rails test')
  end
end

# Override the default rake test task
task test: 'test:via_rails'
