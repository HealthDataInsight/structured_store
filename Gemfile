source 'https://rubygems.org'

# Specify your gem's dependencies in structured_store.gemspec.
gemspec

gem 'puma'

gem 'pg', '~> 1.6'

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem 'rubocop-rails-omakase', require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem 'debug', '>= 1.0.0'

gem 'chronic', '~> 0.10.2'
gem 'mocha', '~> 3.0'
gem 'ndr_dev_support', '~> 7.3'
gem 'rake', '~> 13.3'
gem 'rubocop', '~> 1.82'
gem 'simplecov', '~> 0.22.0'

# CI tests multiple Rails lines by setting RAILS_VERSION (see
# .github/workflows/ci.yml). Unset locally, the gemspec's `rails >= 8.0` wins.
rails_version = ENV.fetch('RAILS_VERSION', nil)
if rails_version
  gem 'rails', "~> #{rails_version}.0"
  # ActiveSupport 8.0.x passes `quirks_mode:` to JSON.generate, which json 3.1.0
  # removed; pin the json 2.x line for that series (Rails 8.1 fixed it).
  gem 'json', '~> 2.19' if rails_version == '8.0'
end
