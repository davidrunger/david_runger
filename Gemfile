# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.1.2'

gem 'active_actions', github: 'davidrunger/active_actions'
gem 'activeadmin'
gem 'active_model_serializers'
gem 'auto_strip_attributes'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'browser'
gem 'chartkick'
gem 'connection_pool'
gem 'dalli'
gem 'devise'
gem 'draper'
gem 'email_reply_trimmer', github: 'davidrunger/email_reply_trimmer'
gem 'faraday'
gem 'faraday-multipart'
# remove GitHub sources after new release relaxes redis constraint to allow redis >= 5.0.5
gem 'flipper', github: 'jnunemaker/flipper'
gem 'flipper-redis', github: 'jnunemaker/flipper'
gem 'flipper-ui'
gem 'hamlit'
gem 'hashid-rails'
gem 'js-routes', '2.2.4', require: false
gem 'jwt'
gem 'lograge'
gem 'mail', '>= 2.8.0.rc1' # remove this listing from Gemfile after a non-rc version is released
gem 'memoist'
gem 'oj'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rails'
gem 'redis'
gem 'redis-client'
gem 'redlock'
gem 'request_store'
gem 'request_store-sidekiq'
gem 'rollbar'
gem 'sassc' # used by ActiveAdmin asset pipeline
gem 'sidekiq', '>=  7.0.0.beta1'
gem 'sprockets-rails'
gem 'vite_rails'

group :production do
  gem 'cloudflare-rails'
end

group :development, :test do
  gem 'amazing_print'
  gem 'annotate', require: false
  gem 'bullet'
  gem 'debug', require: false
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'immigrant'
  gem 'pry-byebug', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'runger_style', github: 'davidrunger/runger_style', require: false
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
  gem 'capybara', github: 'davidrunger/capybara' # remove after teamcapybara/capybara #2590 is fixed
  gem 'capybara-email'
  gem 'capybara-screenshot'
  gem 'climate_control'
  gem 'codecov', require: false
  gem 'database_consistency', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'ferrum'
  gem 'fixture_builder'
  gem 'json-schema'
  gem 'launchy'
  gem 'nokogiri'
  gem 'pallets', github: 'davidrunger/pallets'
  gem 'percy-capybara'
  gem 'rails-controller-testing'
  gem 'rspec-instafail', require: false
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'rspec-wait'
  gem 'selenium-devtools'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simple_cov-formatter-terminal', github: 'davidrunger/simple_cov-formatter-terminal'
  gem 'super_diff'
  gem 'webmock'
end
