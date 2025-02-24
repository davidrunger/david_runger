Hashid::Rails.configure do |config|
  config.salt = ENV.fetch('HASHID_SALT', nil)
  # we'll only use lowercase letters (default setting is to use capitals, as well)
  config.alphabet = (('a'..'z').to_a + ('0'..'9').to_a).join('').freeze
  config.override_find = false
end
