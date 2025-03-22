Aws.config.update(
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'].presence ||
      Rails.application.credentials.aws&.dig(:access_key_id),
    ENV['AWS_SECRET_ACCESS_KEY'].presence ||
      Rails.application.credentials.aws&.dig(:secret_access_key),
  ),
)
