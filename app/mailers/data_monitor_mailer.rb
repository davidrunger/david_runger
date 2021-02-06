# frozen_string_literal: true

class DataMonitorMailer < ApplicationMailer
  def expectation_not_met(check_name, actual_value, expected_range_string, check_run_at)
    @check_name = check_name
    @actual_value = actual_value
    @expected_range_string = expected_range_string
    @check_run_at = check_run_at
    mail(subject: "#{@check_name} failed to meet its expectation 😰")
  end
end
