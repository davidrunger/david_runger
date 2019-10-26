# frozen_string_literal: true

class SidekiqStats
  extend Memoist
  include Sidekiq::Worker

  sidekiq_options(queue: :essential)

  OVERALL_STATS = %i[
    dead_size
    enqueued
    failed
    processed
    processes_size
    retry_size
    scheduled_size
    workers_size
  ].freeze

  def perform
    track_overall_stats
    track_queue_stats
  end

  private

  memoize \
  def stats
    Sidekiq::Stats.new
  end

  memoize \
  def queues
    (SIDEKIQ_QUEUES + stats.queues.keys).uniq
  end

  def track(metric_name, value)
    StatsD.gauge("sidekiq.#{metric_name}", value)
  end

  def track_overall_stats
    OVERALL_STATS.each do |stat_name|
      stat_value = stats.public_send(stat_name)
      track(stat_name, stat_value)
    end
  end

  def track_queue_stats
    queues.each do |queue_name|
      queue = Sidekiq::Queue.new(queue_name)
      track("#{queue_name}.size", queue.size)
      track("#{queue_name}.latency", queue.latency)
    end
  end
end
