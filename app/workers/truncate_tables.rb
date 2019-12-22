# frozen_string_literal: true

class TruncateTables
  include Sidekiq::Worker

  def perform
    Rake::Task['db:truncate_tables'].invoke
  end
end
