# frozen_string_literal: true

# we have a low enough volume of requests that without `STDOUT.sync = true` there is a notable delay
# in logs being written (due to log buffering); set this value so that logs are written in real time
STDOUT.sync = true

Rails.application.configure do
  config.lograge.enabled = (Rails.env.production? || ENV['LOGRAGE_ENABLED'].present?)

  config.lograge.custom_options = ->(event) { DavidRunger::LogBuilder.new(event).extra_logged_data }
end
