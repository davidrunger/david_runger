# frozen_string_literal: true

class PostgresSpaceStats
  include Sidekiq::Worker

  def perform
    Rake::Task['pghero:capture_space_stats'].invoke
  end
end
