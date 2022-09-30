# frozen_string_literal: true

require 'json'
require 'memoist'
require 'securerandom'

class Clock::Task
  extend Forwardable
  extend Memoist

  def_delegators(:@runner, :lock_manager)

  # rubocop:disable Rails/TimeZone
  def initialize(job_name:, schedule_string:, runner:)
    @job_name = job_name
    @schedule = Clock::Schedule.new(schedule_string)
    @runner = runner
  end

  def run
    lock_manager.lock(resource_key(Time.now), 60_000)
    sidekiq_redis.lpush('queue:default', JSON.dump(job_hash))

    nil
  end

  def should_run?
    current_time = Time.now
    @schedule.matches?(current_time) && !already_ran?(current_time)
  end

  private

  def already_ran?(time)
    lock_manager.locked?(resource_key(time))
  end

  def resource_key(time)
    "redlock-locks:#{@job_name}:#{time.strftime('%H:%M')}"
  end

  def job_hash
    # https://github.com/mperham/sidekiq/wiki/FAQ#how-do-i-push-a-job-to-sidekiq-without-ruby
    current_time = Time.now.to_f
    {
      'class' => @job_name,
      'queue' => 'default',
      'args' => [],
      'retry' => true,
      'jid' => SecureRandom.hex(12),
      'created_at' => current_time,
      'enqueued_at' => current_time,
    }
  end

  memoize \
  def sidekiq_redis
    # Our Sidekiq setup uses Redis database number 1 (see config/initializers/sidekiq.rb).
    # We are using `redis` rather than `redis-client` because `redlock` (which we are already using
    # for locking) uses `redis`.
    Redis.new(url: "#{ENV.fetch('REDIS_URL', 'redis://localhost:6379')}/1")
  end
  # rubocop:enable Rails/TimeZone
end
