ruby file: '.ruby-version'

source 'https://rubygems.org'

gem 'activeadmin'
# Remove 'active_attr' after https://github.com/cgriego/active_attr/pull/ 205 is released.
gem 'active_attr', github: 'davidrunger/active_attr', branch: 'leoarnold/rails-8'
gem 'alba'
gem 'aws-sdk-s3'
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
gem 'js-routes', require: false
gem 'jwt'
gem 'lograge'
gem 'memo_wise'
gem 'nokogiri'
gem 'oj'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'paper_trail'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rails'
gem 'ransack'
gem 'redis-client'
gem 'redlock'
gem 'request_store'
gem 'request_store-sidekiq'
gem 'rollbar'
gem 'runger_actions'
gem 'runger_email_reply_trimmer'
gem 'sassc' # used by ActiveAdmin asset pipeline
gem 'sidekiq'
gem 'sprockets-rails'
# Source from RubyGems after https://github.com/rmm5t/strip_attributes/pull/ 73 is released.
gem 'strip_attributes', github: 'davidrunger/strip_attributes', branch: 'leoarnold/rails-8'
gem 'typelizer', github: 'davidrunger/typelizer'
gem 'vite_rails'

group :production do
  gem 'cloudflare-rails'
end

group :development, :test do
  gem 'amazing_print'
  gem 'annotaterb', require: false
  # Source from RubyGems after https://github.com/flyerhzm/bullet/pull/ 721 is released.
  gem 'bullet', github: 'davidrunger/bullet'
  gem 'immigrant'
  gem 'isolator'
  gem 'json-schema'
  gem 'pry-byebug', require: false
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
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'addressable'
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
  gem 'fixture_builder', github: 'davidrunger/fixture_builder'
  gem 'launchy'
  gem 'pallets', github: 'davidrunger/pallets'
  gem 'percy-capybara'
  gem 'rails-controller-testing'
  gem 'rspec-instafail', require: false
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
