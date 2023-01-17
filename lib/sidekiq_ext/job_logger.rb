# frozen_string_literal: true

require 'sidekiq/job_logger'

module SidekiqExt ; end

class SidekiqExt::JobLogger < Sidekiq::JobLogger
  # This is basically copy-pasted from the Sidekiq source code, but we are adding
  # `:queue` and `:args` to `Sidekiq::Context` so that they'll be logged.
  def call(item, queue)
    start = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    Sidekiq::Context.add(:queue, queue)
    json = JSON.dump(item['args'])
    Sidekiq::Context.add(:args, json.size <= 140 ? json : "#{json[0...140]}...]")
    @logger.info('start')

    yield

    Sidekiq::Context.add(:elapsed, elapsed(start))
    @logger.info('done')
    # rubocop:disable Lint/RescueException
    # This is what the Sidekiq source code does, so we'll do it here, too.
  rescue Exception
    # rubocop:enable Lint/RescueException
    Sidekiq::Context.add(:elapsed, elapsed(start))
    @logger.info('fail')

    raise
  end
end
