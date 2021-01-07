# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.2'

gem 'active_actions', github: 'davidrunger/active_actions'
gem 'activeadmin'
gem 'active_model_serializers'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'browser'
gem 'connection_pool'
gem 'dalli'
gem 'devise'
gem 'draper'
gem 'email_reply_trimmer', github: 'discourse/email_reply_trimmer'
gem 'faraday'
gem 'faraday_middleware'
gem 'flamegraph'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'hamlit'
gem 'hashid-rails'
gem 'js-routes', require: false
gem 'lograge'
gem 'memoist'
gem 'newrelic_rpm'
gem 'oj'
gem 'omniauth-google-oauth2'
# remove once https://github.com/omniauth/omniauth/pull/809 is resolved
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'puma', '~> 5.1.1'
gem 'pundit'
gem 'rack-attack'
gem 'rack-mini-profiler', require: false
gem 'rails'
gem 'redis'
gem 'rollbar'
gem 'sassc' # used by ActiveAdmin asset pipeline
gem 'sidekiq'
gem 'sidekiq-scheduler', require: false
gem 'stackprof'
gem 'thread_safe'
gem 'webpacker'

group :development, :test do
  gem 'amazing_print'
  gem 'annotate'
  gem 'climate_control'
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'immigrant'
  gem 'pallets'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
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
  gem 'spring-watcher-listen', github: 'davidrunger/spring-watcher-listen'
end

group :test do
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'codecov', require: false
  gem 'database_consistency', require: false
  gem 'fixture_builder'
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'hashdiff'
  gem 'json-schema'
  gem 'launchy'
  gem 'percy-capybara'
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing'
  gem 'rspec-instafail', require: false
  gem 'rspec_performance_summary', require: false, github: 'davidrunger/rspec_performance_summary'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'super_diff'
  gem 'webmock'
end

group :production do
  gem 'cloudflare-rails'
end
