# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Prepare the ingress controller used to receive mail
  config.action_mailbox.ingress = :mailgun

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  # Render exceptions via ErrorsController
  config.exceptions_app = routes

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  config.public_file_server.enabled = true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  if [
    Rails.application.credentials.aws&.dig(:access_key_id),
    Rails.application.credentials.aws&.dig(:secret_access_key),
  ].all?(&:present?)
    config.active_storage.service = :amazon
  else
    raise(':amazon storage cannot be enabled because not all required credentials are present')
  end

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT).
    tap  { |logger| logger.formatter = config.log_formatter }.
    then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # "info" includes generic and useful information about system operation, but avoids logging too
  # much information to avoid inadvertent exposure of personally identifiable information (PII). If
  # you want to log everything, set the level to "debug".
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Use a different cache store in production.
  config.cache_store =
    :mem_cache_store,
    ENV.fetch('MEMCACHED_URL'),
    { password: ENV.fetch('MEMCACHED_PASSWORD') }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "david_runger_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Email
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  require_relative('../../lib/email/mailgun_via_http.rb')
  config.action_mailer.delivery_method = Email::MailgunViaHttp

  # https://old.reddit.com/r/rails/comments/zmznbi/is_there_a_gem_for_tracking_adhoc_rails_console/j0e6ffu/
  console do
    PaperTrail.request.whodunnit =
      -> {
        @paper_trail_whodunnit ||=
          begin
            name = nil
            until name.present?
              print 'What is your name (used by PaperTrail to record who changed records)? '
              name = gets.chomp
            end
            puts "Thank you, #{name}! Be safe!"
            name
          end
      }
  end
end
