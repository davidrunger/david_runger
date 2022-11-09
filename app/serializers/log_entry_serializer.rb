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

class LogEntrySerializer < ApplicationSerializer
  attributes :id, :data, :log_id, :note

  attribute(:created_at) do |log_entry|
    log_entry.read_attribute_before_type_cast('created_at').iso8601
  end
end
