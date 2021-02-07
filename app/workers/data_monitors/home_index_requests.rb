# frozen_string_literal: true

class DataMonitors::HomeIndexRequests < DataMonitors::Base
  prepend ApplicationWorker

  def perform
    verify_data_expectation(
      check_name: :number_of_requests_in_past_day,
      expectation: (5..500),
    )

    min_response_time = redis_config('average_response_time_in_past_day', 'min', 10)
    max_response_time = redis_config('average_response_time_in_past_day', 'max', 200)
    verify_data_expectation(
      check_name: :average_response_time_in_past_day,
      expectation: (min_response_time..max_response_time),
    )
  end

  private

  def redis_config(key, subkey, backup)
    RedisConfig.get("DataMonitors::HomeIndexRequests.#{key}.#{subkey}", backup).value
  end

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
    requests_in_past_day.average(:total)&.round(1)
  end
end
