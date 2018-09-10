# == Schema Information
#
# Table name: log_entries
#
#  created_at :datetime         not null
#  data       :jsonb            not null
#  id         :bigint(8)        not null, primary key
#  log_id     :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_entries_on_log_id  (log_id)
#

class LogEntrySerializer < ActiveModel::Serializer
  attributes :created_at, :data

  def created_at
    decimal_precision = 0
    log_entry.created_at.iso8601(decimal_precision)
  end

  private

  def log_entry
    object
  end
end
