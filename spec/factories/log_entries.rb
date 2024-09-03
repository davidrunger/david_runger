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
FactoryBot.define do
  factory :log_entry do
    association :log
    association :log_entry_datum
  end
end
