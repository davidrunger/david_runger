# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  # rubocop:disable Lint/PercentStringArray
  config.csp = {
    disable_nonce_backwards_compatibility: true,
    base_uri: %w['self'],
    default_src: %w['self'],
    connect_src: %w['self' wss:],
    font_src: %w['self' cdn.rawgit.com],
    img_src: %w['self' data:],
    object_src: %w['none'],
    script_src: %w['self' 'unsafe-eval'],
    style_src: %w['self' 'unsafe-inline' cdn.rawgit.com],
  }

  if !Rails.env.production?
    config.csp[:connect_src] += %w[http://localhost:3035 ws:]
  end
  # rubocop:enable Lint/PercentStringArray
end
