# == Schema Information
#
# Table name: need_satisfaction_ratings
#
#  check_in_id       :bigint           not null
#  created_at        :datetime         not null
#  emotional_need_id :bigint           not null
#  id                :bigint           not null, primary key
#  score             :integer
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_need_satisfaction_ratings_on_check_in_id        (check_in_id)
#  index_need_satisfaction_ratings_on_emotional_need_id  (emotional_need_id)
#  index_need_satisfaction_ratings_on_user_id            (user_id)
#
FactoryBot.define do
  factory :need_satisfaction_rating do
    association :emotional_need
    association :user
    association :check_in
  end
end
