require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# require_relative is ugly but ~necessary: https://github.com/rails/rails/issues/25525
require_relative '../app/middleware/request_uuid'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DavidRunger ; end
class DavidRunger::Application < Rails::Application
  # Initialize configuration defaults for originally generated Rails version.
  config.load_defaults(5.1)

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Don't generate system test files.
  config.generators.system_tests = nil

  # Time zone
  config.time_zone = 'America/Los_Angeles'
  config.active_record.default_timezone = :local

  config.middleware.insert_after(Rack::MethodOverride, RequestUuid)

  extra_load_paths = [
    Rails.root.join('lib'),
    Rails.root.join(*%w[app controllers lib]),
  ]
  config.autoload_paths.concat(extra_load_paths)
  config.eager_load_paths.concat(extra_load_paths)

  ENV['FIXTURES_PATH'] = 'spec/fixtures'
end
