# rubocop:disable Layout/LineLength

# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }

# You can also remove all the silencers if you're trying to debug a problem that might stem from framework code.
# Rails.backtrace_cleaner.remove_silencers!

Rails.application.config.after_initialize do
  response_serialization_path_prefixes = %w[
    app/controllers/api/base_controller.rb:
    app/controllers/concerns/schema_validatable.rb:
    app/helpers/window_data_helper.rb:
    app/poros/json_schema_validator.rb:
  ].freeze
  query_source_backtrace_cleaner = Rails.backtrace_cleaner.dup
  query_source_backtrace_cleaner.add_silencer do |line|
    line.start_with?(*response_serialization_path_prefixes)
  end

  ActiveRecord::LogSubscriber.backtrace_cleaner = query_source_backtrace_cleaner
end

# rubocop:enable Layout/LineLength
