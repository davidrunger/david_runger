# frozen_string_literal: true

module ErrorLogger
  def self.warn(message:, data: {}, error_klass: StandardError)
    data_log_line = data.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
    Rails.logger.warn(<<~LOG.squish)
      #{error_klass.name}: #{message}
      #{"; #{data_log_line}" if data_log_line.present?}
    LOG

    Rollbar.warn(error_klass.new(message), data)
  end
end
