class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :needed, :store_id
end
