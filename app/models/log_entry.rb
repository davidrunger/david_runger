# == Schema Information
#
# Table name: log_entries
#
#  created_at           :datetime         not null
#  id                   :bigint           not null, primary key
#  log_entry_datum_id   :bigint           not null
#  log_entry_datum_type :string           not null
#  log_id               :bigint           not null
#  note                 :string
#  updated_at           :datetime         not null
#
# Indexes
#
#  idx_on_log_entry_datum_type_log_entry_datum_id_e43ce914c3  (log_entry_datum_type,log_entry_datum_id) UNIQUE
#  index_log_entries_on_log_id                                (log_id)
#
class LogEntry < ApplicationRecord
  include JsonBroadcastable

  belongs_to :log
  has_one :user, through: :log
  delegated_type :log_entry_datum,
    types: %w[NumberLogEntryDatum TextLogEntryDatum],
    inverse_of: :log_entry,
    dependent: :destroy

  validates :log_entry_datum, presence: true
  validates_associated :log_entry_datum

  delegate :data, to: :log_entry_datum

  has_paper_trail

  broadcasts_json_to(LogEntriesChannel, ->(log_entry) { log_entry.log })
end
