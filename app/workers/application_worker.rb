# frozen_string_literal: true

module ApplicationWorker
  include Sidekiq::Worker # rubocop:disable CustomCops/DontIncludeSidekiqWorker

  # borrowed from https://github.com/mperham/sidekiq/blob/v6.1.0/lib/sidekiq/worker.rb#L137-L142
  def self.prepended(base)
    base.include(Sidekiq::Worker::Options)
    base.extend(Sidekiq::Worker::ClassMethods)
  end

  def perform(...)
    disable_flag_name = "disable_#{self.class.name.underscore}_worker".to_sym
    if Flipper.enabled?(disable_flag_name)
      logger.info(<<~LOG.squish)
        Skipping #{self.class.name} job because the `#{disable_flag_name}` flag is enabled.
      LOG
      return
    end

    super
  end
end
