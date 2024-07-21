# we have a low enough volume of requests that without `STDOUT.sync = true` there is a notable delay
# in logs being written (due to log buffering); set this value so that logs are written in real time
$stdout.sync = true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = ->(event) { Logs::LogBuilder.new(event).extra_logged_data }
  config.lograge.formatter = ->(data) { Logs::LogFormatter.new(data).call }
end
