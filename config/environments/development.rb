require 'active_support/core_ext/integer/time'

Rails.application.configure do
  if !IS_DOCKER
    config.after_initialize do
      Bullet.enable = true
      Bullet.rails_logger = true
      Bullet.raise = true
      Bullet.counter_cache_enable = false
    end
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # Make code changes take effect immediately without server restart.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable Action Controller caching. By default Action Controller caching is disabled.
  # Run rails dev:cache to toggle Action Controller caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store =
      :redis_cache_store,
      { url: ENV.fetch('REDIS_CACHE_URL', nil) }
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{Integer(2.days)}",
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Make template changes take effect immediately.
  config.action_mailer.perform_caching = false

  # Set localhost to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Raise exceptions on deprecation notices.
  config.active_support.deprecation = :raise

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Apply autocorrection by RuboCop to files generated by `bin/rails generate`.
  # config.generators.apply_rubocop_autocorrect_after_generate!

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  if !IS_DOCKER
    config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  end

  # Email
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method =
    if Rails.env.development? && IS_DOCKER
      # Merely log, because letter_opener is a development dependency (so not available in Docker).
      Mail::LoggerDelivery
    else
      :letter_opener
    end

  local_hostname = ENV.fetch('LOCAL_HOSTNAME', nil)
  if local_hostname && !local_hostname.empty? # rubocop:disable Rails/Present
    config.hosts << local_hostname
  end
end
