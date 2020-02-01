# frozen_string_literal: true

# This is a base class for Sidekiq workers that send various stats/data/metrics to StatsD.
class Stats::Base
  extend Memoist
  include Sidekiq::Worker

  sidekiq_options(queue: :essential, retry: false)

  private

  def track(metric_name, value)
    StatsD.gauge("#{self.class::METRIC_NAMESPACE}.#{metric_name}", value)
  end
end
