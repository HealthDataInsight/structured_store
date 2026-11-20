# Rails versions the gem is tested against. Regenerate the gemfiles with
# `bundle exec appraisal generate` after editing, and `bundle exec appraisal install`
# to refresh their lockfiles.
appraise 'rails-8.0' do
  gem 'rails', '~> 8.0.0'
  # ActiveSupport 8.0.x still passes `quirks_mode:` to JSON.generate, which the
  # json 3.1.0 release removed; pin to the json 2.x line (Rails 8.1 fixed this).
  gem 'json', '~> 2.19'
end

appraise 'rails-8.1' do
  gem 'rails', '~> 8.1.0'
end
