# == Schema Information
#
# Table name: number_log_entry_data
#
#  created_at :datetime         not null
#  data       :float            not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :number_log_entry_datum do
    data { rand(200) }
  end
end
