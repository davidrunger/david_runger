# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

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

  # Turn false under Spring and add config.action_view.cache_template_loading = true.
  config.cache_classes = ENV.key?('CI')

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = ENV.key?('CI')

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{Integer(1.hour)}" }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :local

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  extra_load_paths = [Rails.root.join('spec/support')].map(&:to_s).map(&:freeze)
  config.eager_load_paths.concat(extra_load_paths)
end

Rails.autoloaders.main.do_not_eager_load(Rails.root.join('spec/support/matchers/'))
