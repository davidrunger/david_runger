DavidRunger::Application.config.secret_key_base =
  ENV.fetch(
    'SECRET_KEY_BASE',
    Rails.application.credentials.secret_key_base,
  ).presence ||
  fail('Could not find a secret_key_base in ENV or credentials.')
