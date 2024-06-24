# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# rubocop:disable Style/RequireOrder
require 'action_cable/engine'
require 'action_controller/railtie'
require 'action_mailbox/engine'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'sprockets/railtie'
# rubocop:enable Style/RequireOrder

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DavidRunger
  CANONICAL_DOMAIN = 'davidrunger.com'

  class << self
    def canonical_url(path)
      "https://#{CANONICAL_DOMAIN}#{path}"
    end
  end

  CANONICAL_URL = canonical_url('/').freeze
end

class DavidRunger::Application < Rails::Application
  # Initialize configuration defaults for originally generated Rails version.
  config.load_defaults(7.0)

  # Please, add to the `ignore` list any other `lib` subdirectories that do
  # not contain `.rb` files, or that should not be reloaded or eager loaded.
  # Common ones are `templates`, `generators`, or `middleware`, for example.
  config.autoload_lib(ignore: %w[tasks])

  # ActiveJob/Sidekiq
  config.active_job.queue_adapter = :sidekiq

  # ActionMailer
  config.action_mailer.default_url_options =
    case Rails.env
    when 'production'
      # :nocov:
      { host: DavidRunger::CANONICAL_DOMAIN, protocol: 'https' }
      # :nocov:
    else
      { host: 'localhost:3000', protocol: 'http' }
    end

  # Configuration for the application, engines, and railties goes here.
  #
  # These settings can be overridden in specific environments using the files
  # in config/environments, which are processed later.

  config.generators.helper = false
  config.generators.system_tests = false
  config.generators do |g|
    g.factory_bot(dir: 'spec/factories')
  end

  config.time_zone = ENV.fetch('TIME_ZONE', 'America/Chicago')
  config.active_record.default_timezone = :utc

  # config.eager_load_paths << Rails.root.join("extras")

  config.middleware.insert_after(ActionDispatch::Static, Rack::Deflater) # gzip all responses
  initializer(
    'move Browser middleware after Rack::Attack',
    after: 'rack-attack.middleware',
  ) do |app|
    app.middleware.move_after(Rack::Attack, Browser::Middleware)
  end

  errors_file = Rails.root.join('lib/errors.rb')
  Rails.autoloaders.main.ignore(errors_file) # must do this bc. `errors.rb` does not define `Error`
  require errors_file

  ENV['FIXTURES_PATH'] ||= 'spec/fixtures' if ENV.fetch('RAILS_ENV', nil) == 'test'

  # Time until incoming mail incineration. Default is 30 days, but we don't need that long.
  config.action_mailbox.incinerate_after = 2.days

  # https://github.com/hotwired/turbo-rails/blob/9d53529/README.md#compatibility-with-rails-ujs
  config.action_view.form_with_generates_remote_forms = false

  config.action_controller.wrap_parameters_by_default = false
end
