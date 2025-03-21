ruby file: '.ruby-version'

source 'https://rubygems.org'

# rubocop:disable Layout/LineLength
gem 'activeadmin'
gem 'addressable'
gem 'alba'
gem 'aws-sdk-s3'
gem 'blazer'
gem 'bootsnap', require: false
gem 'browser'
gem 'chartkick'
gem 'connection_pool'
gem 'csv'
gem 'devise'
gem 'dotenv'
gem 'draper'
gem 'faraday'
gem 'faraday-multipart'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'freezolite'
gem 'haml'
gem 'haml-rails'
gem 'hashid-rails'
gem 'json'
gem 'js-routes', require: false
gem 'jwt'
gem 'lograge'
gem 'memo_wise'
gem 'nokogiri'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'paper_trail', # Source from RubyGems after https://github.com/paper-trail-gem/paper_trail/pull/1511 is released.
  github: 'davidrunger/paper_trail',
  branch: 'avoid-n+1-queries-in-version_limit-when-destroying'
gem 'pg'
gem 'pghero'
gem 'pg_query' # Used by `pghero` and `prosopite`.
gem 'prometheus_exporter'
gem 'propshaft'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rails'
gem 'redis-client'
gem 'redlock'
gem 'request_store'
gem 'request_store-sidekiq'
gem 'rollbar'
gem 'runger_actions'
gem 'runger_email_reply_trimmer'
gem 'runger_rails_model_explorer'
gem 'sidekiq'
gem 'strip_attributes'
gem 'typelizer', github: 'davidrunger/typelizer'
gem 'vite_rails'

group :production do
  gem 'cloudflare-rails'
end

group :development, :test do
  gem 'amazing_print'
  gem 'annotaterb', require: false
  gem 'immigrant'
  gem 'isolator'
  gem 'json-schema'
  gem 'listen'
  gem 'prosopite'
  gem 'pry-byebug', # Go back to upstream if/when https://github.com/deivid-rodriguez/pry-byebug/pull/ 428 is merged.
    require: false,
    github: 'davidrunger/pry-byebug'
  gem 'rainbow'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'runger_style', require: false
  gem 'spring-commands-rspec'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'http_logger'
  gem 'letter_opener'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-screenshot'
  gem 'climate_control'
  gem 'cuprite'
  gem 'database_consistency', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'ferrum'
  gem 'fixture_builder'
  gem 'launchy'
  gem 'pallets', github: 'davidrunger/pallets'
  gem 'percy-capybara'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'rspec-sidekiq'
  gem 'rspec-wait'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-cobertura', require: false
  gem 'simple_cov-formatter-terminal'
  gem 'super_diff'
  gem 'webmock'
end
# rubocop:enable Layout/LineLength
