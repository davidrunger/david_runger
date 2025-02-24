secret_key_base = ENV.fetch('SECRET_KEY_BASE')

if secret_key_base.present?
  DavidRunger::Application.config.secret_key_base = secret_key_base
  # :nocov:
elsif ENV.fetch('SECRET_KEY_BASE_DUMMY', nil) != '1'
  fail('Could not find a secret_key_base in ENV or credentials.')
  # :nocov:
end
