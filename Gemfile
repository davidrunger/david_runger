# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# source from 0-10-stable branch for Rails 6 compatibility (avoids deprecation warnings)
gem 'active_model_serializers', github: 'rails-api/active_model_serializers', branch: '0-10-stable'
gem 'administrate', github: 'thoughtbot/administrate' # source from master for Rails 6 compatibility
gem 'browser'
gem 'devise'
gem 'dotenv-rails', require: 'dotenv/rails-now'
# foreman >= 0.64.0 has stricter version locks for its `dotenv` and `thor` dependencies
gem 'foreman', '~> 0.63.0', require: false
gem 'hamlit'
gem 'httparty'
gem 'js-routes', require: false
gem 'lograge'
gem 'newrelic_rpm'
gem 'oj'
gem 'omniauth-google-oauth2'
gem 'pg', '~> 1.1'
gem 'pg_query', '>= 0.9.0'
gem 'pghero'
gem 'puma', '~> 3.12'
gem 'pundit'
gem 'rails', '>= 6.0.0.rc1'
gem 'redis', '~>4.1'
gem 'rest-client'
gem 'rollbar'
gem 'rubocop', require: false
gem 'rubocop-performance', require: false
gem 'rubocop-rails', require: false
gem 'statsd-instrument'
gem 'webpacker', '>= 4.0.0.pre.pre.2'

group :development, :test do
  gem 'awesome_print'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'fixture_builder'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'flamegraph' # Provides flamegraphs for rack-mini-profiler.
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Performance profiling. Should be listed after `pg` (and `rails`?) gems to get database
  # performance analysis.
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'spring-commands-rspec'
  # We can go back to the offical spring-watcher-listen after upgrading to Rails 6.
  # See https://bit.ly/2Frtra3 (bug) and https://bit.ly/2Fpd50n (fix).
  gem 'spring-watcher-listen', '~> 2.0.2', github: 'davidrunger/spring-watcher-listen'
  gem 'stackprof' # Provides stack traces for flamegraph for rack-mini-profiler.
end

group :test do
  gem 'capybara'
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'launchy' # for save_and_open_page in feature specs
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'webmock'
end
