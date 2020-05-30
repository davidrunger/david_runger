# frozen_string_literal: true

# == Schema Information
#
# Table name: log_entries
#
#  created_at :datetime         not null
#  data       :jsonb            not null
#  id         :bigint           not null, primary key
#  log_id     :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_entries_on_log_id  (log_id)
#

FactoryBot.define do
  factory :log_entry do
    association :log
    data do
      if log.is_a?(LogEntries::NumberLogEntry)
        rand(200)
      else
        Faker::Movies::VForVendetta.quote
      end
    end
  end
end
