source 'https://rubygems.org'
ruby '2.6.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_serializers'
gem 'administrate', '~> 0.11.0'
gem 'browser'
gem 'devise'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'foreman', require: false
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
gem 'rails', '>= 5.2.0.rc1'
gem 'redis', '~>4.1'
gem 'rest-client'
gem 'rollbar'
gem 'rubocop', require: false
gem 'sass-rails', '~> 5.0'
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
  # Provides flamegraphs for rack-mini-profiler.
  gem 'flamegraph'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Performance profiling. Should be listed after `pg` (and `rails`?) gems to get database performance
  # analysis.
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.2', github: 'davidrunger/spring-watcher-listen'
  # Provides stack traces for flamegraph for rack-mini-profiler.
  gem 'stackprof'
end

group :test do
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'webmock'
end
