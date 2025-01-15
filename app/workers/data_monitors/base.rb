class DataMonitors::Base
  include Throttleable
  prepend MemoWise

  TIME_BETWEEN_EMAIL_ALERTS = 1.day.freeze

  private

  def verify_data_expectation(check_name:, expectation:)
    full_check_name = "#{self.class}##{check_name}"
    actual_value = __send__(check_name)

    if actual_satisfies_expectation?(actual: actual_value, expected: expectation)
      Rails.logger.info(<<~LOG.squish)
        Check "#{full_check_name}" was satisfied (expectation: `#{expectation}`,
        actual value: `#{actual_value}`).
      LOG
    else
      log_message_parts = [<<~LOG]
        Check "#{full_check_name}" was NOT satisfied (expectation: `#{expectation}`,
        actual value: `#{actual_value}`).
      LOG

      if skip_email?
        log_message_parts << 'Skipping email because we are in development and running in Docker.'
      end

      Rails.logger.info(log_message_parts.join(' ').squish)

      unless skip_email?
        lock_key = "#{full_check_name}:email-alert"
        throttled('email admin', lock_key, TIME_BETWEEN_EMAIL_ALERTS) do
          DataMonitorMailer.expectation_not_met(
            full_check_name,
            actual_value,
            expectation.to_s,
            Time.current.to_s,
          ).deliver_later
        end
      end
    end
  end

  def actual_satisfies_expectation?(actual:, expected:)
    case expected
    when Range then expected.cover?(actual)
    else actual == expected
    end
  end

  memo_wise \
  def skip_email?
    Rails.env.development? && IS_DOCKER
  end
end
