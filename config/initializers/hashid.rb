# frozen_string_literal: true

Hashid::Rails.configure do |config|
  config.salt = ENV['HEROKU_APP_NAME'].presence || Rails.application.credentials.hashid_salt
  # we'll only use lowercase letters (default setting is to use capitals, as well)
  config.alphabet = (('a'..'z').to_a + ('0'..'9').to_a).join('').freeze
  config.override_find = false
end
