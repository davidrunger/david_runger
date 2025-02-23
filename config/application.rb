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
# rubocop:enable Style/RequireOrder

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'freezolite/auto'

require_relative '../lib/memoization.rb'

IS_DOCKER_BUILD = ENV.key?('DOCKER_BUILD')
IS_DOCKER_BUILT = ENV.key?('DOCKER_BUILT')
IS_DOCKER = IS_DOCKER_BUILD || IS_DOCKER_BUILT

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
  config.load_defaults(8.0)

  # We enable YJIT for the web server only in config/initializers/enable_yjit.rb.
  config.yjit = false

  # Please, add to the `ignore` list any other `lib` subdirectories that do
  # not contain `.rb` files, or that should not be reloaded or eager loaded.
  # Common ones are `templates`, `generators`, or `middleware`, for example.
  config.autoload_lib(ignore: %w[generators tasks test])

  # ActiveJob/Sidekiq
  config.active_job.queue_adapter = :sidekiq

  # Configuration for the application, engines, and railties goes here.
  #
  # These settings can be overridden in specific environments using the files
  # in config/environments, which are processed later.

  config.time_zone = ENV.fetch('TIME_ZONE', 'America/Chicago')
  config.active_record.default_timezone = :utc

  # Append comments with runtime information tags to SQL queries in logs.
  config.active_record.query_log_tags_enabled = true
  config.active_record.query_log_tags = %i[namespaced_controller action job]

  # config.eager_load_paths << Rails.root.join("extras")

  config.generators.helper = nil
  # Don't generate system test files.
  config.generators.system_tests = nil
  config.generators do |g|
    g.factory_bot(dir: 'spec/factories')
  end

  if Rails.env.local?
    require Rails.root.join('lib/middleware/early')
    initializer('insert early middleware', after: 'vite_rails.proxy') do |app|
      app.middleware.insert_before(0, Middleware::Early)
    end

    if !IS_DOCKER
      require Rails.root.join('tools/json_schemas_to_typescript')
      initializer 'listen to (re)generate JSON-schema-to-TypeScript-types files' do |app|
        JsonSchemasToTypescript.initialize_listener(app)
      end
    end
  end

  initializer(
    'move Browser middleware after Rack::Attack',
    after: 'rack-attack.middleware',
  ) do |app|
    app.middleware.move_after(Rack::Attack, Browser::Middleware)
  end

  errors_file = Rails.root.join('lib/errors.rb')
  Rails.autoloaders.main.ignore(errors_file) # must do this bc. `errors.rb` does not define `Errors`
  require errors_file

  ENV['FIXTURES_PATH'] ||= 'spec/fixtures' if ENV.fetch('RAILS_ENV', nil) == 'test'

  # Time until incoming mail incineration. Default is 30 days, but we don't need that long.
  config.action_mailbox.incinerate_after = 2.days

  # https://github.com/hotwired/turbo-rails/blob/9d53529/README.md#compatibility-with-rails-ujs
  config.action_view.form_with_generates_remote_forms = false

  config.action_controller.wrap_parameters_by_default = false

  # The log size limit causes tailing a log file to stop working when the limit
  # is reached, which is annoying, so disable the limit.
  config.log_file_size = nil

  # Allow access from other services in the Docker Compose network.
  config.hosts << 'web:3000'
end
