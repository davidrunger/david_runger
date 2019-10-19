# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

# require_relative is ugly but ~necessary: https://github.com/rails/rails/issues/25525
require_relative '../app/middleware/request_uuid'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DavidRunger ; end
class DavidRunger::Application < Rails::Application
  # Initialize configuration defaults for originally generated Rails version.
  config.load_defaults('6.0')

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Don't generate system test files.
  config.generators.system_tests = nil

  # Time zone
  config.time_zone = 'America/Los_Angeles'
  config.active_record.default_timezone = :utc

  config.middleware.insert_after(ActionDispatch::Static, Rack::Deflater) # gzip all responses
  config.middleware.insert_after(Rack::MethodOverride, RequestUuid)

  extra_load_paths = [
    Rails.root.join('lib'),
    Rails.root.join(*%w[lib refinements]),
    Rails.root.join(*%w[app controllers lib]),
  ]
  config.autoload_paths.concat(extra_load_paths)
  config.eager_load_paths.concat(extra_load_paths)
  config.add_autoload_paths_to_load_path = false
  # Hack (?) to avoid e.g. LoadError: cannot load such file -- devise_helper caused by rails
  # 6.0.0.rc1 to 6.0.0.rc2 upgrade, probably due to `add_autoload_paths_to_load_path` config option
  # now being respected.
  $LOAD_PATH << File.join(Gem.loaded_specs['administrate'].full_gem_path, 'app', 'helpers').to_s
  $LOAD_PATH << File.join(Gem.loaded_specs['devise'].full_gem_path, 'app', 'helpers').to_s
  $LOAD_PATH << File.join(Gem.loaded_specs['pghero'].full_gem_path, 'app', 'helpers').to_s

  ENV['FIXTURES_PATH'] = 'spec/fixtures'
end

# necessary to avoid an error that otherwise occurs when Zeitwerk eager-loads the application. The
# error (e.g. "expected file
# /home/travis/build/davidrunger/david_runger/vendor/bundle/ruby/2.6.0/gems/devise-4.6.2/app/mailers/devise/mailer.rb
# to define constant Devise::Mailer, but didn't") is caused by the fact that we aren't using
# ActionMailer, and Devise only defines `Devise::Mailer` `if defined?(ActionMailer)` (see
# https://github.com/plataformatec/devise/blob/v4.6.2/app/mailers/devise/mailer.rb#L3).
absolute_devise_gem_path = Gem.loaded_specs['devise'].full_gem_path
absolute_devise_mailer_path =
  File.join(absolute_devise_gem_path, 'app', 'mailers', 'devise', 'mailer.rb')
Rails.autoloaders.main.do_not_eager_load(absolute_devise_mailer_path)
