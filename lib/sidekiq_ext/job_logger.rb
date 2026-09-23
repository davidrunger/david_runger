require 'sidekiq/component'
require 'sidekiq/job_logger'
require 'sidekiq_ext/job_arguments_formatter'

module SidekiqExt ; end

class SidekiqExt::JobLogger < Sidekiq::JobLogger
  # This is basically copy-pasted from the Sidekiq source code, but we are adding
  # memory measurements, `:queue`, and `:args` to `Sidekiq::Context` so that
  # they'll be logged.
  def call(item, queue)
    start = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    memory_before = memory_stats
    Sidekiq::Context.add(:queue, queue)
    Sidekiq::Context.add(:args, SidekiqExt::JobArgumentsFormatter.new.call(item['args']))
    add_memory_stats(memory_before, :before)
    @logger.info('start')

    yield

    Sidekiq::Context.add(:elapsed, elapsed(start))
    add_memory_after_stats(memory_before)
    @logger.info('done')
    # rubocop:disable Lint/RescueException
    # This is what the Sidekiq source code does, so we'll do it here, too.
  rescue Exception
    # rubocop:enable Lint/RescueException
    Sidekiq::Context.add(:elapsed, elapsed(start))
    add_memory_after_stats(memory_before)
    @logger.info('fail')

    raise
  end

  private

  def memory_stats
    {
      process_memory_kib:,
      heap_allocated_pages: GC.stat(:heap_allocated_pages),
    }
  end

  def process_memory_kib
    memory_values = {}
    File.foreach('/proc/self/status').each do |line|
      name, value = line.split(':', 2)

      if %w[VmRSS VmSwap].include?(name)
        memory_values[name] = Integer(value.split.first, 10)
      end
    end

    if memory_values.size == 2
      memory_values.values.sum
    end
  rescue SystemCallError, IOError
    nil
  end

  def add_memory_stats(stats, suffix)
    stats.each do |name, value|
      Sidekiq::Context.add(:"#{name}_#{suffix}", value)
    end
  end

  def add_memory_after_stats(memory_before)
    memory_after = memory_stats
    add_memory_stats(memory_after, :after)

    memory_before.each do |name, before_value|
      after_value = memory_after[name]
      delta =
        if before_value.nil? || after_value.nil?
          nil
        else
          after_value - before_value
        end

      Sidekiq::Context.add(:"#{name}_delta", delta)
    end
  end
end
