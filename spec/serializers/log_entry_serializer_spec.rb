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
RSpec.describe LogEntrySerializer do
  let(:log_entry) { LogEntry.first! }

  specify do
    expect(LogEntrySerializer.new(log_entry).to_json).to match_schema('api/log_entries/show')
  end
end
