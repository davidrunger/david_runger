# == Schema Information
#
# Table name: exercises
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_exercises_on_user_id  (user_id)
#

FactoryBot.define do
  factory :exercise do
    user { User.first! }
    name 'Chin-ups'
  end
end
