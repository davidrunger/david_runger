# frozen_string_literal: true

class DataMonitors::HomeIndexRequests < DataMonitors::Base
  prepend ApplicationWorker

  def perform
    verify_data_expectation(
      check_name: :number_of_requests_in_past_day,
      expectation: (5..500),
    )

    accessor = RedisConfig::Accessor.new("#{self.class.name}.median_response_time_in_past_day")
    verify_data_expectation(
      check_name: :median_response_time_in_past_day,
      expectation: (accessor.get('min', 10)..accessor.get('max', 100)),
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

  def median_response_time_in_past_day
    requests_in_past_day.
      select('PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY "total") AS "percentile"').
      to_a.first.percentile&.
      round(1)
  end
end
