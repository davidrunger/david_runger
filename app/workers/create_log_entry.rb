# frozen_string_literal: true

class CreateLogEntry
  include Sidekiq::Worker

  def perform(log_entry_klass, log_entry_attributes)
    klass = log_entry_klass.constantize
    klass.create!(log_entry_attributes)
  end
end
