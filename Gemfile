# rubocop:disable Style/MethodCallWithArgsParentheses
source 'https://rubygems.org'
ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_serializers'
gem 'administrate', '~> 0.8.1'
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
gem 'pg', '~> 0.21'
gem 'pghero'
gem 'pg_query', '>= 0.9.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 5.1.0'
gem 'redis', '~>4.0'
gem 'rest-client'
gem 'rollbar'
gem 'rubocop', require: false
gem 'sass-rails', '~> 5.0'
gem 'statsd-instrument'
gem 'webpacker'

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
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'webmock'
end
