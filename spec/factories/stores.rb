# frozen_string_literal: true

# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint
#  viewed_at  :datetime
#
# Indexes
#
#  index_stores_on_user_id  (user_id)
#

FactoryBot.define do
  factory :store do
    name { Faker::Company.name }
    association :user
    viewed_at { [nil, 1.month.ago, 1.day.ago].sample }
  end
end
