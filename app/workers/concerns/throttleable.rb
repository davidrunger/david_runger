module Throttleable
  prepend Memoization

  private

  def throttled(action_description, lock_key, min_spacing_duration)
    spacing_in_milliseconds = Integer(min_spacing_duration) * 1_000
    if lock_manager.lock("redlock-locks:#{lock_key}", spacing_in_milliseconds)
      yield
    else
      Rails.logger.info(<<~LOG.squish)
        Skipping "#{action_description}" because "#{lock_key}" lock was not acquired.
      LOG
    end
  end

  memoize \
  def lock_manager
    Redlock::Client.new([$redis_pool], retry_count: 0)
  end
end
