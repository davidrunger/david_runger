# == Schema Information
#
# Table name: items
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  needed     :integer          default(1), not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_items_on_user_id_and_lower_name  (user_id, lower((name)::text)) UNIQUE
#
FactoryBot.define do
  factory :item do
    transient do
      stores { [] }
    end

    user { stores.first&.user || association(:user) }
    name { generate(:item_name) }
    needed { rand(2) }

    after(:build) do |item, evaluator|
      if evaluator.stores.any?
        item.stores = evaluator.stores
      else
        item.stores << build(:store, user: item.user)
      end
    end

    trait :needed do
      needed { rand(1..2) }
    end

    trait :unneeded do
      needed { 0 }
    end
  end
end
