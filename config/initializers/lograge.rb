Rails.application.configure do
  config.lograge.enabled = (Rails.env.production? || ENV['LOGRAGE_ENABLED'].present?)

  config.lograge.custom_options = ->(event) { DavidRunger::LogBuilder.new(event).extra_logged_data }
end
