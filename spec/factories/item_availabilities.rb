# == Schema Information
#
# Table name: item_availabilities
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  item_id    :bigint           not null
#  store_id   :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_item_availabilities_on_item_id_and_store_id  (item_id,store_id) UNIQUE
#  index_item_availabilities_on_store_id              (store_id)
#
FactoryBot.define do
  factory :item_availability do
    association :item
    store { association(:store, user: item.user) }
  end
end
