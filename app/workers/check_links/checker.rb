class CheckLinks::Checker
  prepend Memoization
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
  REDIRECTING_URL_REGEX = /\A(#{redirecting_url_prefixes.map { Regexp.escape(it) }.join('|')}).+/
  URL_STATUS_EXPECTATIONS = [
    [LOGGED_IN_DAVID_RUNGER_DOT_COM_REGEX, 302],
    [REDIRECTING_URL_REGEX, 302],
    [%r{\Ahttps://github\.com/.+/blob/.+}, [200, 429]],
  ].freeze

  def perform(url, page_source_url)
    status = response(url)&.status
    expected_statuses = expected_statuses(url, status)

    Rails.logger.info(<<~LOG.squish)
      [#{self.class.name}] #{url} returned #{status.inspect}
      (expected #{expected_statuses.join(' or ')}).
    LOG

    if !status.in?(expected_statuses)
      redis_failure_key = redis_failure_key(url)

      previous_failure_count =
        Integer($redis_pool.with { it.call('get', redis_failure_key) } || 0)

      failure_count = previous_failure_count + 1

      $redis_pool.with { it.call('setex', redis_failure_key, Integer(2.days), failure_count) }

      if failure_count >= 2
        AdminMailer.
          broken_link(url, page_source_url, status, expected_statuses).
          deliver_later
      end
    end
  end

  private

  def expected_statuses(url, status)
    code_expected_statuses =
      Array(URL_STATUS_EXPECTATIONS.find { url.match?(it.first) }&.last || 200).dup

    if status.in?(code_expected_statuses)
      code_expected_statuses
    else
      code_expected_statuses.concat(
        LinkStatusExpectation.where(url:).order(:status).pluck(:status),
      )
    end
  end

  def redis_failure_key(url)
    "link_check:#{url}:failed"
  end

  memoize \
  def response(url)
    Rails.cache.fetch(cache_key(url), expires_in: 6.hours, skip_nil: true) do
      Rails.error.handle(severity: :info, context: { url: }) do
        SafeExternalHttpFetcher.new.get(url, timeout: 5)
      end
    end
  end

  memoize \
  def cache_key(url)
    [LINK_CHECK_CACHE_KEY_PREFIX, url]
  end
end
