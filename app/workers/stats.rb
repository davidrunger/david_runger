# frozen_string_literal: true

class Stats
  include Sidekiq::Worker

  def perform
    StatsD.gauge('counts.users', User.count)
  end
end
