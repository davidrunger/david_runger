# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_serializers', '~> 0.10.10'
gem 'administrate'
gem 'browser'
gem 'connection_pool'
gem 'dalli'
gem 'devise'
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
gem 'pg', '~> 1.2'
gem 'pg_query', '>= 0.9.0'
gem 'pghero'
gem 'puma', '~> 4.3'
gem 'pundit'
gem 'rails', '>= 6.0.2.1', github: 'rails/rails'
gem 'redis', '~>4.1'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler', require: false # required manually in config/initializers/sidekiq.rb
gem 'skylight'
gem 'statsd-instrument'
gem 'thread_safe'
gem 'webpacker', '>= 4.0.0.pre.pre.2'

group :development, :test do
  gem 'awesome_print'
  gem 'brakeman', require: false
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'fixture_builder'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'flamegraph' # Provides flamegraphs for rack-mini-profiler.
  gem 'letter_opener'
  gem 'listen', '>= 3.0.5', '< 3.3'
  # Performance profiling. Should be listed after `pg` (and `rails`?) gems to get database
  # performance analysis.
  gem 'rack-mini-profiler', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  # We can go back to the offical spring-watcher-listen after upgrading to Rails 6.
  # See https://bit.ly/2Frtra3 (bug) and https://bit.ly/2Fpd50n (fix).
  gem 'spring-watcher-listen', '~> 2.0.2', github: 'davidrunger/spring-watcher-listen'
  gem 'stackprof' # Provides stack traces for flamegraph for rack-mini-profiler.
end

group :test do
  gem 'capybara'
  gem 'codecov', require: false
  # note: to use guard-espect from command line, it will also have to be installed "globally"
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  # TEMP: list hashdiff explicitly in Gemfile to force 1.0.0.beta1; remove once 1.0.0 is released
  gem 'hashdiff', '1.0.1'
  # for testing ActiveModelSerializers
  gem 'json-schema'
  gem 'launchy' # for save_and_open_page in feature specs
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.3'
  gem 'webmock'
end
