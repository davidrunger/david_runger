class Email::UserGeneratedDeliveryLimiter
  prepend Memoization

  class CircuitBreakerOpened < StandardError ; end

  Limit = Data.define(:name, :maximum, :period)
  Quota = Data.define(:limit, :key)
  Result =
    Data.define(:permitted, :limit_name, :retry_after) do
      def permitted?
        permitted
      end
    end

  ACTOR_HOUR_LIMIT = Limit.new(name: :actor_hour, maximum: 10, period: 1.hour)
  ACTOR_DAY_LIMIT = Limit.new(name: :actor_day, maximum: 25, period: 1.day)
  ACTOR_LIMITS = [ACTOR_HOUR_LIMIT, ACTOR_DAY_LIMIT].freeze

  ACTOR_RECIPIENT_15_MINUTES_LIMIT =
    Limit.new(name: :actor_recipient_15_minutes, maximum: 5, period: 15.minutes)
  ACTOR_RECIPIENT_DAY_LIMIT =
    Limit.new(name: :actor_recipient_day, maximum: 15, period: 1.day)
  ACTOR_RECIPIENT_LIMITS = [
    ACTOR_RECIPIENT_15_MINUTES_LIMIT,
    ACTOR_RECIPIENT_DAY_LIMIT,
  ].freeze

  RECIPIENT_HOUR_LIMIT = Limit.new(name: :recipient_hour, maximum: 20, period: 1.hour)
  RECIPIENT_DAY_LIMIT = Limit.new(name: :recipient_day, maximum: 50, period: 1.day)
  RECIPIENT_LIMITS = [RECIPIENT_HOUR_LIMIT, RECIPIENT_DAY_LIMIT].freeze
  GLOBAL_LIMIT = Limit.new(name: :global_hour, maximum: 100, period: 1.hour)

  LIMIT_REACHED_MESSAGE = 'Email rate limit reached. Please try again later.'
  EMAIL_NOT_SENT_MESSAGE = 'The email was not sent because the email rate limit was reached.'
  REDIS_KEY_PREFIX = 'user-generated-email-limits:v1'

  RESERVE_SCRIPT = <<~LUA
    local quota_count = #KEYS - 1
    local global_quota_index = tonumber(ARGV[(quota_count * 2) + 1])

    for index = 1, quota_count do
      local current_count = tonumber(redis.call('GET', KEYS[index]) or '0')
      local maximum = tonumber(ARGV[index])

      if current_count >= maximum then
        local retry_after = math.max(redis.call('TTL', KEYS[index]), 1)
        local circuit_breaker_opened = 0

        if index == global_quota_index then
          local alert_was_set = redis.call(
            'SET',
            KEYS[quota_count + 1],
            '1',
            'EX',
            retry_after,
            'NX'
          )

          if alert_was_set then
            circuit_breaker_opened = 1
          end
        end

        return { 0, index, current_count + 1, retry_after, circuit_breaker_opened }
      end
    end

    for index = 1, quota_count do
      local count = redis.call('INCR', KEYS[index])

      if count == 1 then
        redis.call('EXPIRE', KEYS[index], ARGV[quota_count + index])
      end
    end

    return { 1 }
  LUA

  class << self
    def reserve(actor:, recipient_email:, category:)
      new(actor:, recipient_email:, category:).reserve
    end
  end

  def initialize(actor:, recipient_email:, category:)
    @actor_id = actor.id
    @recipient_email = recipient_email.strip.downcase
    @category = category
  end

  def reserve
    redis_result = reserve_in_redis

    if Integer(redis_result.fetch(0)) == 1
      Result.new(permitted: true, limit_name: nil, retry_after: nil)
    else
      denied_result(redis_result:)
    end
  rescue RedisClient::Error => error
    Rails.error.report(
      error,
      context: delivery_context.merge(limit_name: :redis_unavailable),
    )

    Result.new(permitted: true, limit_name: :redis_unavailable, retry_after: nil)
  end

  private

  attr_reader :actor_id, :category, :recipient_email

  memoize \
  def applicable_quotas
    [
      build_quota(GLOBAL_LIMIT),
      *ACTOR_LIMITS.map { build_quota(it, actor_id) },
      *ACTOR_RECIPIENT_LIMITS.map { build_quota(it, actor_id, recipient_email) },
      *RECIPIENT_LIMITS.map { build_quota(it, recipient_email) },
    ]
  end

  def build_quota(limit, *discriminators)
    Quota.new(
      limit:,
      key: [REDIS_KEY_PREFIX, limit.name, *discriminators].join(':'),
    )
  end

  def reserve_in_redis
    keys = [*applicable_quotas.map(&:key), circuit_breaker_alert_key]
    global_quota_index = applicable_quotas.index { it.limit == GLOBAL_LIMIT } + 1
    arguments = [
      *applicable_quotas.map { it.limit.maximum },
      *applicable_quotas.map { Integer(it.limit.period) },
      global_quota_index,
    ]

    $email_quota_redis_pool.with do |connection|
      connection.call(
        'EVAL',
        RESERVE_SCRIPT,
        keys.length,
        *keys,
        *arguments,
      )
    end
  end

  def circuit_breaker_alert_key
    "#{REDIS_KEY_PREFIX}:circuit_breaker_alerted"
  end

  def denied_result(redis_result:)
    quota = applicable_quotas.fetch(Integer(redis_result.fetch(1)) - 1)
    attempted_count = Integer(redis_result.fetch(2))
    retry_after = Integer(redis_result.fetch(3))
    circuit_breaker_opened = Integer(redis_result.fetch(4)) == 1

    log_denial(quota:, attempted_count:, retry_after:)
    report_opened_circuit_breaker(quota:, attempted_count:, retry_after:) if circuit_breaker_opened

    Result.new(
      permitted: false,
      limit_name: quota.limit.name,
      retry_after:,
    )
  end

  def log_denial(quota:, attempted_count:, retry_after:)
    Rails.logger.warn(<<~LOG.squish)
      [user-generated-email-limit]
      category=#{category}
      actor_id=#{actor_id}
      recipient_email=#{recipient_email.inspect}
      limit_name=#{quota.limit.name}
      limit=#{quota.limit.maximum}
      attempted_count=#{attempted_count}
      retry_after_seconds=#{retry_after}
    LOG
  end

  def report_opened_circuit_breaker(quota:, attempted_count:, retry_after:)
    context =
      delivery_context.merge(
        limit_name: quota.limit.name,
        limit: quota.limit.maximum,
        period_seconds: Integer(quota.limit.period),
        attempted_count:,
        retry_after_seconds: retry_after,
      )

    Rails.error.report(
      Error.new(CircuitBreakerOpened, 'User-generated email circuit breaker opened'),
      context:,
    )
    AdminMailer.user_generated_email_circuit_open(context).deliver_later
  end

  def delivery_context
    {
      category:,
      actor_id:,
      recipient_email:,
    }
  end
end
