# frozen_string_literal: true

if Rails.env.development?
  # :nocov:
  HttpLogger.log_headers = true
  # :nocov:
end
