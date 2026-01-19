# avoid OmniAuth output being sent to STDOUT during tests
OmniAuth.config.logger = Rails.logger

# https://github.com/cookpad/omniauth-rails_csrf_protection/pull/24#issuecomment-3492077627
OmniAuth.config.request_validation_phase =
  OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)

Rails.application.config.middleware.use(OmniAuth::Builder) do
  unless IS_DOCKER_BUILD
    provider(
      :google_oauth2,
      ENV.fetch('GOOGLE_OAUTH_CLIENT_ID'),
      ENV.fetch('GOOGLE_OAUTH_CLIENT_SECRET'),
      scope: 'email',
      # a better name would be `is_callback_path' (https://github.com/omniauth/omniauth/issues/630)
      callback_path: ->(env) do
        env['REQUEST_PATH'].to_s.start_with?(%r{/(admin_)?users/auth/google_oauth2/callback(/|\?|\z)})
      end,
    )
  end
end
