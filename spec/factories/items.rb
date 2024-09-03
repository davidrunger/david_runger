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
#  index_items_on_store_id_and_name  (store_id,name) UNIQUE
#
FactoryBot.define do
  factory :item do
    name { generate(:item_name) }
    needed { rand(2) }

    trait :needed do
      needed { rand(1..2) }
    end

    trait :unneeded do
      needed { 0 }
    end
  end
end
