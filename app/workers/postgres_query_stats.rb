# frozen_string_literal: true

class PostgresQueryStats
  include Sidekiq::Worker

  def perform
    system('bin/rails pghero:capture_query_stats') || fail('pghero:capture_query_stats failed')
  end
end
