# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_serializers'
gem 'administrate'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'browser'
gem 'connection_pool'
gem 'dalli'
gem 'devise'
gem 'email_reply_trimmer', github: 'discourse/email_reply_trimmer'
gem 'flamegraph' # Provides flamegraphs for rack-mini-profiler.
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'hamlit'
gem 'httparty'
gem 'js-routes', require: false
gem 'lograge'
gem 'memoist'
gem 'newrelic_rpm'
gem 'oj'
gem 'omniauth-google-oauth2'
# remove once https://github.com/omniauth/omniauth/pull/809 is resolved
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'puma', '~> 5.0.0.beta1'
gem 'pundit'
gem 'rack-attack'
gem 'rack-mini-profiler', require: false
gem 'rails', github: 'rails/rails'
gem 'redis'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler', require: false # required manually in config/initializers/sidekiq.rb
gem 'stackprof' # Provides stack traces for flamegraph for rack-mini-profiler.
gem 'thread_safe'
gem 'webpacker'

group :development, :test do
  gem 'amazing_print'
  gem 'annotate'
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
  gem 'spring-commands-rspec'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'http_logger'
  gem 'letter_opener'
  gem 'listen'
  # Performance profiling. Should be listed after `pg` (and `rails`?) gems to get database
  # performance analysis.
  gem 'spring'
  # We can go back to the offical spring-watcher-listen after upgrading to Rails 6.
  # See https://bit.ly/2Frtra3 (bug) and https://bit.ly/2Fpd50n (fix).
  gem 'spring-watcher-listen', github: 'davidrunger/spring-watcher-listen'
end

group :test do
  gem 'brakeman', require: false
  gem 'capybara'
  gem 'codecov', require: false
  gem 'database_consistency', require: false
  gem 'fixture_builder'
  # note: to use guard-espect from command line, it will also have to be installed "globally"
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'hashdiff'
  # for testing ActiveModelSerializers
  gem 'json-schema'
  gem 'launchy' # for save_and_open_page in feature specs
  gem 'percy-capybara'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webmock'
end
