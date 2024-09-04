# == Schema Information
#
# Table name: text_log_entry_data
#
#  created_at :datetime         not null
#  data       :text             not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :text_log_entry_datum do
    data { Faker::Movies::HarryPotter.quote }
  end
end
