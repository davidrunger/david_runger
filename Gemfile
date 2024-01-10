# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').rstrip

gem 'activeadmin'
gem 'alba'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'browser'
gem 'chartkick'
gem 'connection_pool'
gem 'dalli'
gem 'devise'
gem 'draper'
gem 'faraday'
gem 'faraday-multipart'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
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
gem 'rails-reverse-proxy'
gem 'redis-client'
gem 'redlock', github: 'davidrunger/redlock-rb'
gem 'request_store'
gem 'request_store-sidekiq'
gem 'rollbar'
gem 'runger_actions'
gem 'runger_email_reply_trimmer'
gem 'sassc' # used by ActiveAdmin asset pipeline
gem 'sidekiq'
gem 'sprockets-rails'
gem 'strip_attributes'
gem 'vite_rails'

group :production do
  gem 'cloudflare-rails'
end

group :development, :test do
  gem 'amazing_print'
  gem 'annotate', require: false
  gem 'bullet'
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'immigrant'
  gem 'isolator'
  gem 'pry-byebug', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'runger_style', require: false
  gem 'solargraph', require: false
  gem 'spring-commands-rspec'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hotwire-livereload'
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
  gem 'fixture_builder'
  gem 'json-schema'
  gem 'launchy'
  gem 'pallets', github: 'davidrunger/pallets'
  gem 'percy-capybara'
  gem 'rails-controller-testing'
  gem 'rspec-instafail', require: false
  gem 'rspec-rails'
  gem 'rspec-wait'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-cobertura', require: false
  gem 'simple_cov-formatter-terminal'
  gem 'super_diff'
  gem 'webmock'
end
