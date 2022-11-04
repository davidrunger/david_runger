# frozen_string_literal: true

class CheckHomeLinks::Checker
  extend Memoist
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
      AdminMailer.bad_home_link(url, status, expected_statuses).deliver_later
    end
  end

  private

  memoize \
  def response(url)
    Faraday.new.get do |request|
      request.url(url)
      request.options.timeout = 5
    end
  rescue => error
    Rollbar.warn(error, url:)
    nil
  end
end
