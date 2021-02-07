# frozen_string_literal: true

class DataMonitors::Base
  extend Memoist

  MILLISECONDS_BETWEEN_EMAIL_ALERTS = Integer(1.day) * 1_000

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
      Rails.logger.info(<<~LOG.squish)
        Check "#{full_check_name}" was NOT satisfied (expectation: `#{expectation}`,
        actual value: `#{actual_value}`).
      LOG

      email_lock_key = "redlock-locks:#{full_check_name}:email-alert"
      if lock_manager.lock(email_lock_key, MILLISECONDS_BETWEEN_EMAIL_ALERTS)
        DataMonitorMailer.expectation_not_met(
          full_check_name,
          actual_value,
          expectation.to_s,
          Time.current.to_s,
        ).deliver_later
      else
        Rails.logger.info(%(Skipping email because "#{email_lock_key}" lock was not acquired.))
      end
    end
  end

  def actual_satisfies_expectation?(actual:, expected:)
    case expected
    when Range then expected.cover?(actual)
    else actual == expected
    end
  end

  memoize \
  def lock_manager
    Redlock::Client.new([$redis_pool], retry_count: 0)
  end
end
