# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.0.2'

gem 'active_actions', github: 'davidrunger/active_actions'
gem 'activeadmin'
gem 'active_model_serializers'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'browser'
gem 'chartkick'
gem 'connection_pool'
gem 'dalli'
gem 'devise'
gem 'draper'
gem 'email_reply_trimmer', github: 'discourse/email_reply_trimmer'
gem 'faraday'
gem 'faraday_middleware'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'hamlit'
gem 'hashid-rails'
gem 'heat', git: 'https://github.com/davidrunger/heat.git', require: false
gem 'js-routes', require: false
gem 'lograge'
gem 'memoist'
gem 'newrelic_rpm'
gem 'oj'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rack-attack'
gem 'rails'
gem 'redd', github: 'davidrunger/redd', require: false
gem 'redis'
gem 'redlock'
gem 'request_store'
gem 'request_store-sidekiq'
gem 'rollbar'
gem 'sassc' # used by ActiveAdmin asset pipeline
gem 'sidekiq'
gem 'sidekiq-scheduler', require: false
gem 'webpacker'

group :production do
  gem 'cloudflare-rails'
end

group :development, :test do
  gem 'amazing_print'
  gem 'annotate', require: false
  gem 'bullet'
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'immigrant'
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
  gem 'vite_rails'
end

group :test do
  gem 'addressable'
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'climate_control'
  gem 'codecov', require: false
  gem 'database_consistency', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'ferrum'
  gem 'fixture_builder'
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'json-schema'
  gem 'launchy'
  gem 'nokogiri'
  gem 'pallets'
  gem 'percy-capybara'
  gem 'rails-controller-testing', github: 'rails/rails-controller-testing'
  gem 'rspec-instafail', require: false
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'super_diff'
  gem 'webmock'
end
