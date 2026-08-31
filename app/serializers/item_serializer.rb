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
class ItemSerializer < ApplicationSerializer
  attributes :id, :name, :needed

  typelize 'Array<number>'
  attribute(:store_ids) do |item|
    item.item_availabilities.map(&:store_id)
  end
end
