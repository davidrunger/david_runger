class CheckLinks::Checker
  prepend MemoWise
  prepend ApplicationWorker

  LINK_CHECK_CACHE_KEY_PREFIX = 'link-check'
  LOGGED_IN_DAVID_RUNGER_DOT_COM_REGEX = %r{
    \A
    https://davidrunger.com/
    (?:
      check_ins
      | groceries
      | logs
      | my_account
      | quizzes
      | workout
    )
    /?
    \z
  }x
  redirecting_url_prefixes = %w[
    https://gem.wtf/
    https://ghub.io/
    https://github.com/davidrunger/blog/edit/main/src/_posts/
  ].map(&:freeze).freeze
  REDIRECTING_URL_REGEX = /\A(#{redirecting_url_prefixes.map { Regexp.escape(_1) }.join('|')}).+/
  # rubocop:disable Style/MutableConstant
  STATUS_EXPECTATIONS = {
    'https://www.commonlit.org/' => [200, 403],
    'https://www.linkedin.com/in/davidrunger/' => [200, 429, 999],
    'https://www.termsfeed.com/privacy-policy-generator/' => [200, 403],
    'https://www.termsfeed.com/blog/cookies/#What_Are_Cookies' => [200, 403],
  }
  STATUS_EXPECTATIONS.default_proc =
    proc do |_hash, url|
      if (
        url.match?(LOGGED_IN_DAVID_RUNGER_DOT_COM_REGEX) ||
          url.match?(REDIRECTING_URL_REGEX)
      )
        302
      else
        200
      end
    end
  STATUS_EXPECTATIONS.freeze
  # rubocop:enable Style/MutableConstant

  def perform(url, page_source_url)
    status = response(url)&.status
    expected_statuses = Array(STATUS_EXPECTATIONS[url])

    Rails.logger.info(<<~LOG.squish)
      [#{self.class.name}] #{url} returned #{status.inspect}
      (expected #{expected_statuses.map(&:to_s).join(' or ')}).
    LOG

    if !status.in?(expected_statuses)
      previous_failure_count =
        Integer($redis_pool.with { _1.call('get', redis_failure_key(url)) } || 0)

      failure_count = previous_failure_count + 1

      $redis_pool.with { _1.call('setex', redis_failure_key(url), Integer(2.days), failure_count) }

      if failure_count >= 2
        AdminMailer.
          broken_link(url, page_source_url, status, expected_statuses).
          deliver_later
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
    Rails.cache.fetch(cache_key(url), expires_in: 6.hours) do
      Rails.error.handle(severity: :info, context: { url: }) do
        Faraday.new.get do |request|
          request.url(url)
          request.options.timeout = 5
        end
      end
    end
  end

  memo_wise \
  def cache_key(url)
    [LINK_CHECK_CACHE_KEY_PREFIX, url]
  end
end
