# frozen_string_literal: true

class DataMonitors::Base
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
      DataMonitorMailer.expectation_not_met(
        full_check_name,
        actual_value,
        expectation.to_s,
        Time.current.to_s,
      ).deliver_later
    end
  end

  def actual_satisfies_expectation?(actual:, expected:)
    case expected
    when Range then expected.cover?(actual)
    else actual == expected
    end
  end
end
