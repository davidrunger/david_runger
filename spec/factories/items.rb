# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  needed     :integer          default(1), not null
#  store_id   :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_items_on_store_id  (store_id)
#

FactoryBot.define do
  factory :item do
    name { Faker::Food.unique.ingredient }
    needed { rand(2) }

    trait :needed do
      needed { rand(1..8) }
    end

    trait :unneeded do
      needed { 0 }
    end
  end
end
