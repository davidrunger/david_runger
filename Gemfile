source 'https://rubygems.org'
ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.0'
gem 'dotenv-rails', groups: [:development, :test], require: 'dotenv/rails-now'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'webpacker'
gem 'jbuilder', '~> 2.5'
gem 'devise', github: 'plataformatec/devise'
gem 'omniauth-google-oauth2'
gem 'hamlit'
gem 'redis', '~>3.2'
gem 'browser'
gem 'rollbar'
gem 'newrelic_rpm'
gem 'administrate', github: 'thoughtbot/administrate' # installed from `master` for Rails 5.1 compat
gem 'oj'
gem 'active_model_serializers'
gem 'httparty'
gem 'js-routes'

group :development, :test do
  gem 'fixture_builder'
  gem 'awesome_print'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-espect', require: false, github: 'davidrunger/guard-espect'
  gem 'faker'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'annotate'
end
