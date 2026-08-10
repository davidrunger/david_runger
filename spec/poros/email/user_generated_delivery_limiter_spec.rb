RSpec.describe Email::UserGeneratedDeliveryLimiter, queue_adapter: :test do
  let(:actor_id) { 123 }
  let(:recipient_email) { 'recipient@example.com' }
  let(:category) { :proposal }
  let(:reserve_delivery) do
    lambda do |actor_id: 123, recipient_email: 'recipient@example.com', category: :proposal|
      described_class.reserve(
        actor: User.new(id: actor_id),
        recipient_email:,
        category:,
      )
    end
  end

  before { allow(Rails.logger).to receive(:warn) }

  describe 'configured limits' do
    it 'uses the intended actor limits' do
      expect(described_class::ACTOR_LIMITS.map(&:to_h)).to eq([
        { name: :actor_hour, maximum: 10, period: 1.hour },
        { name: :actor_day, maximum: 25, period: 1.day },
      ])
    end

    it 'uses the intended actor-recipient limits' do
      expect(described_class::ACTOR_RECIPIENT_LIMITS.map(&:to_h)).to eq([
        { name: :actor_recipient_15_minutes, maximum: 5, period: 15.minutes },
        { name: :actor_recipient_day, maximum: 15, period: 1.day },
      ])
    end

    it 'uses the intended recipient limits' do
      expect(described_class::RECIPIENT_LIMITS.map(&:to_h)).to eq([
        { name: :recipient_hour, maximum: 20, period: 1.hour },
        { name: :recipient_day, maximum: 50, period: 1.day },
      ])
    end

    it 'uses the intended global circuit-breaker limit' do
      expect(described_class::GLOBAL_LIMIT.to_h).to eq(
        name: :global_hour,
        maximum: 100,
        period: 1.hour,
      )
    end
  end

  describe '::reserve' do
    it 'permits a delivery below every limit' do
      result = reserve_delivery.call(actor_id:, recipient_email:, category:)

      expect(result).to be_permitted
      expect(result.limit_name).to eq(nil)
      expect(result.retry_after).to eq(nil)
    end

    it 'uses the normalized recipient address in observable Redis keys' do
      reserve_delivery.call(
        actor_id:,
        recipient_email: '  Recipient@Example.COM  ',
        category:,
      )

      keys =
        $email_quota_redis_pool.with do |connection|
          connection.call('KEYS', "#{described_class::REDIS_KEY_PREFIX}:*")
        end

      expect(keys).to include(
        "#{described_class::REDIS_KEY_PREFIX}:actor_recipient_15_minutes:123:recipient@example.com",
      )
    end

    it 'shares a normalized actor-recipient limit across email categories' do
      described_class::ACTOR_RECIPIENT_15_MINUTES_LIMIT.maximum.times do |index|
        result =
          reserve_delivery.call(
            actor_id:,
            recipient_email: index.even? ? '  Recipient@Example.COM  ' : recipient_email,
            category: %i[proposal log_share comment_reply].fetch(index % 3),
          )

        expect(result).to be_permitted
      end

      denied_result =
        reserve_delivery.call(actor_id:, recipient_email:, category: :comment_reply)

      expect(denied_result).not_to be_permitted
      expect(denied_result.limit_name).to eq(:actor_recipient_15_minutes)
      expect(denied_result.retry_after).to be_between(1, 15.minutes)
      expect(Rails.logger).
        to have_received(:warn).
        with(
          a_string_including(
            '[user-generated-email-limit]',
            'category=comment_reply',
            'actor_id=123',
            'recipient_email="recipient@example.com"',
            'limit_name=actor_recipient_15_minutes',
            'limit=5',
            'attempted_count=6',
          ),
        )
    end

    it 'limits an actor across recipients' do
      described_class::ACTOR_HOUR_LIMIT.maximum.times do |index|
        expect(
          reserve_delivery.call(actor_id:, recipient_email: "recipient-#{index}@example.com"),
        ).to be_permitted
      end

      denied_result =
        reserve_delivery.call(actor_id:, recipient_email: 'another-recipient@example.com')

      expect(denied_result).not_to be_permitted
      expect(denied_result.limit_name).to eq(:actor_hour)
    end

    it 'limits a recipient across actors' do
      described_class::RECIPIENT_HOUR_LIMIT.maximum.times do |index|
        expect(reserve_delivery.call(actor_id: index, recipient_email:)).to be_permitted
      end

      denied_result =
        reserve_delivery.call(
          actor_id: described_class::RECIPIENT_HOUR_LIMIT.maximum,
          recipient_email:,
        )

      expect(denied_result).not_to be_permitted
      expect(denied_result.limit_name).to eq(:recipient_hour)
    end

    it 'reserves an actor-recipient quota atomically under concurrency' do
      actor = User.new(id: actor_id)
      ready_queue = Queue.new
      start_queue = Queue.new
      concurrent_reservation_count =
        described_class::ACTOR_RECIPIENT_15_MINUTES_LIMIT.maximum * 2
      threads =
        Array.new(concurrent_reservation_count) do
          Thread.new do
            ready_queue << true
            start_queue.pop
            described_class.reserve(actor:, recipient_email:, category:)
          end
        end

      concurrent_reservation_count.times { ready_queue.pop }
      concurrent_reservation_count.times { start_queue << true }
      results = threads.map(&:value)

      expect(results.count(&:permitted?)).to eq(
        described_class::ACTOR_RECIPIENT_15_MINUTES_LIMIT.maximum,
      )
      expect(results.reject(&:permitted?).map(&:limit_name).uniq).
        to eq([:actor_recipient_15_minutes])
    end

    context 'when the global circuit breaker opens' do
      before do
        allow(Rails.error).to receive(:report).and_call_original
      end

      it 'prioritizes the global limit and reports and emails its opening only once' do
        described_class::GLOBAL_LIMIT.maximum.times do |index|
          expect(
            reserve_delivery.call(
              actor_id: index < described_class::ACTOR_HOUR_LIMIT.maximum ? 0 : index,
              recipient_email: "recipient-#{index}@example.com",
            ),
          ).to be_permitted
        end

        denied_result = nil
        expect {
          denied_result = reserve_delivery.call(
            actor_id: 0,
            recipient_email: 'triggering-recipient@example.com',
            category: :log_share,
          )
        }.to have_enqueued_mail(
          AdminMailer,
          :user_generated_email_circuit_open,
        ).with(hash_including(actor_id: 0, limit_name: :global_hour))

        expect(denied_result).not_to be_permitted
        second_denied_result =
          reserve_delivery.call(
            actor_id: 102,
            recipient_email: 'another-recipient@example.com',
            category: :comment_reply,
          )

        expect(second_denied_result.limit_name).to eq(:global_hour)
        expect(Rails.error).
          to have_received(:report).
          with(
            an_instance_of(described_class::CircuitBreakerOpened),
            context: hash_including(
              category: :log_share,
              actor_id: 0,
              recipient_email: 'triggering-recipient@example.com',
              limit_name: :global_hour,
              limit: 100,
              attempted_count: 101,
            ),
          ).
          once
        expect(second_denied_result).not_to be_permitted
      end
    end

    context 'when Redis is unavailable' do
      it 'fails open and reports the Redis error' do
        redis_error = RedisClient::CannotConnectError.new('Redis unavailable')
        allow($email_quota_redis_pool).to receive(:with).and_raise(redis_error)
        allow(Rails.error).to receive(:report).and_call_original

        result = reserve_delivery.call(actor_id:, recipient_email:, category:)

        expect(result).to be_permitted
        expect(result.limit_name).to eq(:redis_unavailable)
        expect(result.retry_after).to eq(nil)
        expect(Rails.error).
          to have_received(:report).
          with(
            redis_error,
            context: {
              category:,
              actor_id:,
              recipient_email:,
              limit_name: :redis_unavailable,
            },
          )
      end
    end
  end

  describe '::reserve_global' do
    it 'limits global-only deliveries across categories' do
      described_class::GLOBAL_LIMIT.maximum.times do |index|
        result =
          described_class.reserve_global(
            category: %i[log_reminder reply_forwarding webhook_email_forward].fetch(index % 3),
          )

        expect(result).to be_permitted
      end

      denied_result = described_class.reserve_global(category: :log_reminder)

      expect(denied_result).not_to be_permitted
      expect(denied_result.limit_name).to eq(:global_hour)
    end
  end
end
