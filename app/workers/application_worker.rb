require 'digest/sha1'

module ApplicationWorker
  prepend Memoization
  include Sidekiq::Worker # rubocop:disable CustomCops/DontIncludeSidekiqWorker
  include SpacedLaunching

  MAX_RETRY_WAIT_TIME = 30 # seconds

  module ClassMethods
    def unique_while_executing!
      @unique_while_executing = true
    end

    def unique_while_executing?
      !!@unique_while_executing
    end
  end

  def self.prepended(base)
    # borrowed from https://github.com/sidekiq/sidekiq/blob/v6.1.0/lib/sidekiq/worker.rb#L137-L142
    base.include(Sidekiq::Worker::Options)
    base.extend(Sidekiq::Worker::ClassMethods)

    base.extend(ApplicationWorker::ClassMethods)
  end

  def perform(*args)
    with_lock_or_reschedule(args) do
      disable_flag_name = :"disable_#{self.class.name.underscore}_worker"
      if Flipper.enabled?(disable_flag_name)
        logger.info(<<~LOG.squish)
          Skipping #{self.class.name} job because the `#{disable_flag_name}` flag is enabled.
        LOG
        return
      end

      super
    end
  end

  private

  def with_lock_or_reschedule(args)
    if !unique_while_executing? || lock_obtained?(args)
      begin
        yield
      ensure
        remove_lock(args) if unique_while_executing?
      end
    else
      reschedule(args)
    end
  end

  def unique_while_executing?
    self.class.unique_while_executing?
  end

  def lock_obtained?(args)
    Sidekiq.redis do |conn|
      conn.call('set', lock_key(args), 'locked', nx: true, ex: MAX_RETRY_WAIT_TIME)
    end
  end

  def reschedule(args)
    reschedule_wait = rand((1..MAX_RETRY_WAIT_TIME))
    Rails.logger.info(<<~LOG.squish)
      Rescheduling #{self.class.name} worker with args #{args}
      in #{reschedule_wait} seconds because uniqueness lock
      could not be obtained.
    LOG
    self.class.perform_in(reschedule_wait, *args)
  end

  def remove_lock(args)
    Sidekiq.redis do |conn|
      conn.call('del', lock_key(args))
    end
  end

  memoize \
  def lock_key(args)
    "sidekiq-unique:#{self.class.name}:#{Digest::SHA1.hexdigest(JSON.dump(args))}"
  end
end
