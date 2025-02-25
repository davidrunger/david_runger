Rollbar.configure do |config|
  code_version = ENV.fetch('GIT_REV') { `git log --format=format:%H | head -n 1`.rstrip }

  access_token =
    case Rails.env
    # :nocov:
    when 'production'
      if IS_DOCKER_BUILD
        nil
      else
        ENV.fetch('ROLLBAR_ACCESS_TOKEN')
      end
    # :nocov:
    else ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)
    end

  config.access_token = access_token
  config.code_version = code_version

  # Without configuration, Rollbar is enabled in all environments.
  # To disable in specific environments, set config.enabled=false.
  if Rails.env.in?(%w[development test])
    config.enabled = access_token.present? && (!IS_DOCKER || ENV.key?('ENABLE_ROLLBAR'))
  end

  # NOTE: Instead of having Rollbar send uncaught errors on its own, we will
  # send them to Rollbar via our Rails ErrorSubscriber.
  config.capture_uncaught = false

  # By default, Rollbar will try to call the `current_user` controller method
  # to fetch the logged-in user object, and then call that object's `id`,
  # `username`, and `email` methods to fetch those properties. To customize:
  # config.person_method = "my_current_user"
  # config.person_id_method = "my_id"
  config.person_username_method = 'email'
  config.person_email_method = 'email'

  # If you want to attach custom data to all exception and message reports,
  # provide a lambda like the following. It should return a hash.
  # config.custom_data_method = lambda { {:some_key => "some_value" } }

  # Add exception class names to the exception_level_filters hash to
  # change the level that exception is reported at. Note that if an exception
  # has already been reported and logged the level will need to be changed
  # via the rollbar interface.
  # Valid levels: 'critical', 'error', 'warning', 'info', 'debug', 'ignore'
  # 'ignore' will cause the exception to not be reported at all.
  config.exception_level_filters.merge!(
    'ActionController::BadRequest' => 'info',
    'ActionController::RoutingError' => 'info',
    'ActionDispatch::Http::MimeNegotiation::InvalidType' => 'info',
  )
  #
  # You can also specify a callable, which will be called with the exception instance.
  # config.exception_level_filters.merge!('MyCriticalException' => lambda { |e| 'critical' })

  # Enable asynchronous reporting (uses girl_friday or Threading if girl_friday
  # is not installed)
  # config.use_async = true
  # Supply your own async handler:
  # config.async_handler = Proc.new { |payload|
  #  Thread.new { Rollbar.process_from_async_handler(payload) }
  # }

  # Enable asynchronous reporting (using sucker_punch)
  # config.use_sucker_punch

  # Enable delayed reporting (using Sidekiq)
  config.use_sidekiq
  config.async_json_payload = true # https://github.com/rollbar/rollbar-gem/issues/ 1077
  # You can supply custom Sidekiq options:
  # config.use_sidekiq 'queue' => 'default'

  # If you run your staging application instance in production environment then
  # you'll want to override the environment reported by `Rails.env` with an
  # environment variable like this: `ROLLBAR_ENV=staging`. This is a recommended
  # setup for Heroku. See:
  # https://devcenter.heroku.com/articles/deploying-to-a-custom-rails-environment
  config.environment = ENV.fetch('ROLLBAR_ENV', Rails.env)

  client_token = ENV.fetch('ROLLBAR_POST_CLIENT_ITEM_ACCESS_TOKEN', nil)
  config.js_enabled = IS_DOCKER_BUILD ? false : Flipper.enabled?(:rollbar_js)
  config.js_options = {
    accessToken: client_token,
    captureUncaught: true,
    captureUnhandledRejections: true,
    payload: {
      environment: Rails.env,
      client: {
        javascript: {
          source_map_enabled: true,
          code_version:,
          guess_uncaught_frames: true,
        },
      },
      server: {
        root: '/app',
      },
    },
  }
end
