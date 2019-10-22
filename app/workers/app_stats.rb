# frozen_string_literal: true

class AppStats
  include Sidekiq::Worker

  def perform
    StatsD.gauge('counts.users', User.count)
  end
end
