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

class LogEntry < ApplicationRecord
  belongs_to :log
  validates :data, presence: true
end
