# frozen_string_literal: true

class TruncateTables
  include Sidekiq::Worker

  def perform
    system('bin/rails db:truncate_tables') || fail('db:truncate_tables failed')
  end
end
