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

class LogEntry < ApplicationRecord
  belongs_to :log
  has_one :user, through: :log

  validates :data, presence: true
end
