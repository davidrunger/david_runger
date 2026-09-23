class CheckLinks::Checker
  prepend Memoization
  prepend ApplicationWorker

  LINK_CHECK_CACHE_KEY_PREFIX = 'link-check-status'
  USER_AGENT = "DavidRungerLinkChecker/1.0 (+#{DavidRunger::CANONICAL_URL})".freeze
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
    response_info = response_info(url)
    status = response_info[:status]
    expected_statuses = expected_statuses(url, status)

    logger.info(<<~LOG.squish)
      #{url} returned #{status.inspect} (expected #{expected_statuses.join(' or ')}).
      response_cache=#{response_info[:cache_status]}
      response_body_bytes=#{response_info[:body_bytes].inspect}
      response_header_bytes_approx=#{response_info[:header_bytes_approx].inspect}
      response_size_bytes_approx=#{response_info[:size_bytes_approx].inspect}
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
  def response_info(url)
    cache_hit = true
    response_size = nil
    status =
      Rails.cache.fetch(cache_key(url), expires_in: 6.hours, skip_nil: true) do
        cache_hit = false
        Rails.error.handle(severity: :info, context: { url: }) do
          response = SafeExternalHttpFetcher.new.get(url, timeout: 5, user_agent: USER_AGENT)
          response_size = response_size_metrics(response)

          response.status
        end
      end

    {
      status:,
      cache_status: cache_hit ? 'hit' : 'miss',
      body_bytes: response_size&.fetch(:body_bytes),
      header_bytes_approx: response_size&.fetch(:header_bytes_approx),
      size_bytes_approx: response_size&.fetch(:size_bytes_approx),
    }
  end

  def response_size_metrics(response)
    body_bytes = response.body.to_s.bytesize
    # Faraday exposes parsed headers, so this estimates their text size, not wire bytes.
    header_bytes_approx =
      response.headers.sum do |name, value|
        name.to_s.bytesize + value.to_s.bytesize + 4
      end + 2

    {
      body_bytes:,
      header_bytes_approx:,
      size_bytes_approx: body_bytes + header_bytes_approx,
    }
  end

  memoize \
  def cache_key(url)
    [LINK_CHECK_CACHE_KEY_PREFIX, url]
  end
end
