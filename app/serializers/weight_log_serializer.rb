class WeightLogSerializer < ActiveModel::Serializer
  attributes :created_at, :id, :note, :weight
end
