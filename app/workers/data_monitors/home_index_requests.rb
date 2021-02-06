# frozen_string_literal: true

class DataMonitors::HomeIndexRequests < DataMonitors::Base
  prepend ApplicationWorker

  def perform
    verify_data_expectation(
      check_name: :number_of_requests_in_past_day,
      expectation: (5..500),
    )

    verify_data_expectation(
      check_name: :average_response_time_in_past_day,
      expectation: (10..200),
    )
  end

  private

  def requests_in_past_day
    Request.
      where(handler: 'home#index').
      where(requested_at: 1.day.ago..).
      where.not(total: nil)
  end

  def number_of_requests_in_past_day
    requests_in_past_day.size
  end

  def average_response_time_in_past_day
    requests_in_past_day.average(:total)
  end
end
