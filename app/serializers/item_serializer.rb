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

class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :needed, :store_id
end
