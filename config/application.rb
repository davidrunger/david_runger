# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'action_cable/engine'
require 'action_controller/railtie'
require 'action_mailbox/engine'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DavidRunger ; end

class DavidRunger::Application < Rails::Application
  # Initialize configuration defaults for originally generated Rails version.
  config.load_defaults('6.0')

  # ActiveJob/Sidekiq
  config.active_job.queue_adapter = :sidekiq

  # ActionMailer
  config.action_mailer.default_url_options =
    case Rails.env
    when 'production'
      # :nocov:
      { host: 'davidrunger.com', protocol: 'https' }
      # :nocov:
    else
      { host: 'localhost:3000', protocol: 'http' }
    end

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Don't generate system test files.
  config.generators.system_tests = nil
  config.generators do |g|
    g.factory_bot(dir: 'spec/factories')
  end

  # Time zone
  config.time_zone = 'America/Los_Angeles'
  config.active_record.default_timezone = :utc

  config.middleware.insert_after(ActionDispatch::Static, Rack::Deflater) # gzip all responses

  extra_load_paths = [
    Rails.root.join('lib'),
    Rails.root.join(*%w[lib refinements]),
    Rails.root.join(*%w[app controllers lib]),
  ].map(&:to_s).map(&:freeze)
  config.eager_load_paths.concat(extra_load_paths)
  config.add_autoload_paths_to_load_path = false
  # Hack (?) to avoid e.g. LoadError: cannot load such file -- devise_helper caused by rails
  # 6.0.0.rc1 to 6.0.0.rc2 upgrade, probably due to `add_autoload_paths_to_load_path` config option
  # now being respected.
  $LOAD_PATH << File.join(Gem.loaded_specs['devise'].full_gem_path, 'app', 'helpers').to_s

  ENV['FIXTURES_PATH'] = 'spec/fixtures'

  # Time until incoming mail incineration. Default is 30 days, but we don't need that long.
  config.action_mailbox.incinerate_after = 1.day

  # https://github.com/hotwired/turbo-rails/blob/9d53529/README.md#compatibility-with-rails-ujs
  config.action_view.form_with_generates_remote_forms = false
end
