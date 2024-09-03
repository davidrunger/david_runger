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
class LogEntrySerializer < ApplicationSerializer
  attributes :id, :log_id, :note

  attribute(:created_at) do |log_entry|
    log_entry.read_attribute_before_type_cast('created_at').iso8601
  end

  attribute(:data) do |log_entry|
    log_entry.log_entry_datum.data
  end
end
