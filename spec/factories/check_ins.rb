# == Schema Information
#
# Table name: check_ins
#
#  created_at  :datetime         not null
#  id          :bigint           not null, primary key
#  marriage_id :bigint           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_check_ins_on_marriage_id  (marriage_id)
#
FactoryBot.define do
  factory :check_in
end
