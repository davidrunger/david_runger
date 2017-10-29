# rubocop:disable Style/MethodCallWithArgsParentheses
source 'https://rubygems.org'
ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_serializers'
gem 'administrate', github: 'thoughtbot/administrate' # installed from `master` for Rails 5.1 compat
gem 'browser'
gem 'devise', github: 'plataformatec/devise'
gem 'dotenv-rails', groups: %i[development test], require: 'dotenv/rails-now'
gem 'hamlit'
gem 'httparty'
gem 'jbuilder', '~> 2.5'
gem 'js-routes'
gem 'newrelic_rpm'
gem 'oj'
gem 'omniauth-google-oauth2'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.0'
gem 'redis', '~>3.2'
gem 'rollbar'
gem 'rubocop'
gem 'sass-rails', '~> 5.0'
gem 'webpacker'

group :development, :test do
  gem 'awesome_print'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fixture_builder'
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
