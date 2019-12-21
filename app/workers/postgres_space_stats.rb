# frozen_string_literal: true

class PostgresSpaceStats
  include Sidekiq::Worker

  def perform
    system('bin/rails pghero:capture_space_stats') || fail('pghero:capture_space_stats failed')
  end
end
