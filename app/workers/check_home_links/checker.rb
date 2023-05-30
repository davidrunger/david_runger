# frozen_string_literal: true

class CheckHomeLinks::Checker
  prepend MemoWise
  prepend ApplicationWorker

  # rubocop:disable Style/MutableConstant
  STATUS_EXPECTATIONS = {
    'https://davidrunger.com/check_ins/' => 302,
    'https://davidrunger.com/groceries/' => 302,
    'https://davidrunger.com/logs/' => 302,
    'https://davidrunger.com/quizzes/' => 302,
    'https://davidrunger.com/workout/' => 302,
    'https://www.linkedin.com/in/davidrunger/' => [200, 999],
  }
  STATUS_EXPECTATIONS.default = 200
  STATUS_EXPECTATIONS.freeze
  # rubocop:enable Style/MutableConstant

  def perform(url)
    status = response(url)&.status
    expected_statuses = Array(STATUS_EXPECTATIONS[url])

    Rails.logger.info(<<~LOG.squish)
      [#{self.class.name}] #{url} returned #{status.inspect}
      (expected #{expected_statuses.map(&:to_s).join(' or ')}).
    LOG

    if !status.in?(expected_statuses)
      previous_failure_count =
        Integer($redis_pool.with { _1.call('get', redis_failure_key(url)) } || 0)
      new_failure_count = previous_failure_count + 1

      $redis_pool.
        with { _1.call('setex', redis_failure_key(url), Integer(2.days), new_failure_count) }

      if new_failure_count >= 2
        AdminMailer.bad_home_link(url, status, expected_statuses).deliver_later
      end
    end
  end

  private

  memo_wise \
  def redis_failure_key(url)
    "link_check:#{url}:failed"
  end

  memo_wise \
  def response(url)
    Faraday.new.get do |request|
      request.url(url)
      request.options.timeout = 5
    end
  rescue => error
    Rollbar.info(error, url:)
    nil
  end
end
