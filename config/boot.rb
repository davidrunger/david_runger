ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# rubocop:disable Style/RequireOrder
require 'bundler/setup' # Set up gems listed in the Gemfile.
unless ENV.fetch('CI', nil) == 'true'
  require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
end
# rubocop:enable Style/RequireOrder
