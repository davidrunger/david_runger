# frozen_string_literal: true

class PostgresQueryStats
  include Sidekiq::Worker

  def perform
    Rake::Task['pghero:capture_query_stats'].invoke
  end
end
