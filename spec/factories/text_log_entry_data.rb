# == Schema Information
#
# Table name: text_log_entry_data
#
#  created_at :datetime         not null
#  data       :text             not null
#  id         :bigint           not null, primary key
#  log_id     :bigint
#  note       :string
#  updated_at :datetime         not null
#
# Indexes
#
#  index_text_log_entry_data_on_log_id  (log_id)
#
FactoryBot.define do
  factory :text_log_entry_datum do
    data { Faker::Movies::HarryPotter.quote }
  end
end
