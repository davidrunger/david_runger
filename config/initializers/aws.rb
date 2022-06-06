# frozen_string_literal: true

# rubocop:disable Rails/SaveBang
Aws.config.update(
  credentials: Aws::Credentials.new(
    Rails.application.credentials.aws&.dig(:access_key_id),
    Rails.application.credentials.aws&.dig(:secret_access_key),
  ),
)
# rubocop:enable Rails/SaveBang
