# frozen_string_literal: true

# avoid OmniAuth output being sent to STDOUT during tests
OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use(OmniAuth::Builder) do
  provider(
    :google_oauth2,
    Rails.application.credentials.google&.dig(:oauth_client_id),
    Rails.application.credentials.google&.dig(:oauth_client_secret),
    scope: 'email',
    # a better name would be `is_callback_path' (https://github.com/omniauth/omniauth/issues/630)
    callback_path: ->(env) do
      env['REQUEST_PATH'].to_s.start_with?(%r{/(admin_)?users/auth/google_oauth2/callback(/|\?|\z)})
    end,
  )
end
