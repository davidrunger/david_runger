require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Prepare the ingress controller used to receive mail
  config.action_mailbox.ingress = :mailgun

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true
  # Render exceptions via ErrorsController.
  config.exceptions_app = routes

  # rubocop:disable Layout/LineLength
  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # rubocop:enable Layout/LineLength
  config.require_master_key = !IS_DOCKER_BUILD

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  config.public_file_server.enabled = false

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  if %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY].all? { ENV[_1].present? }
    config.active_storage.service = :amazon
  elsif !IS_DOCKER_BUILD
    raise(':amazon storage cannot be enabled because not all required credentials are present')
  end

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT).
    tap  { |logger| logger.formatter = config.log_formatter }.
    then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  unless IS_DOCKER_BUILD
    # Use a different cache store in production.
    config.cache_store =
      :redis_cache_store,
      { url: ENV.fetch('REDIS_CACHE_URL') }
  end

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options =
    { host: DavidRunger::CANONICAL_DOMAIN, protocol: 'https' }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Use all attributes for inspections in production.
  config.active_record.attributes_for_inspect = :all

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [
    'davidrunger.com', # Allow requests from davidrunger.com.
    /.*\.davidrunger\.com/, # Allow requests from subdomains like `www.davidrunger.com`.
    'web:3000', # Allow access from other services in the Docker Compose network.
  ]
  #
  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == '/up' } }

  # Email
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  require_relative('../../lib/email/mailgun_via_http.rb')
  config.action_mailer.delivery_method = Email::MailgunViaHttp

  # https://old.reddit.com/r/rails/comments/zmznbi/is_there_a_gem_for_tracking_adhoc_rails_console/j0e6ffu/
  console do
    PaperTrail.request.whodunnit =
      -> do
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
      end
  end
end
