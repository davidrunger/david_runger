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

class LogEntry < ApplicationRecord
  include JsonBroadcastable

  self.abstract_class = true

  belongs_to :log
  has_one :user, through: :log

  validates :data, presence: true

  broadcasts_json_to(LogEntriesChannel, ->(log_entry) { log_entry.log })

  def self.policy_class
    LogEntryPolicy
  end

  def self.serializer_class
    LogEntrySerializer
  end
end
