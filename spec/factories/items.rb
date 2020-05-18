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
    name { 'milk' }
    needed { 1 }
  end
end
