# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.raise = true
    Bullet.counter_cache_enable = false
  end

  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = ENV['CI'].blank?

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600',
  }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Render exceptions via ErrorsController
  config.exceptions_app = routes

  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :local

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.
  # https://github.com/DavyJonesLocker/capybara-email#setting-your-test-host
  config.action_mailer.default_url_options = { host: 'localhost', port: 3001 }

  # Raise exceptions on deprecation notices.
  config.active_support.deprecation = :raise

  config.active_record.verbose_query_logs = true

  config.log_level =
    if ENV.fetch('TEST_LOGGING', nil) == '1'
      # :nocov:
      :debug
    # :nocov:
    else
      :warn
    end

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  extra_load_paths = [Rails.root.join('spec/support')].map { _1.to_s.freeze }
  config.eager_load_paths.concat(extra_load_paths)
end

Rails.autoloaders.main.do_not_eager_load(Rails.root.join('spec/support/matchers/'))
Rails.autoloaders.main.do_not_eager_load(Rails.root.join('spec/support/selectors/'))
