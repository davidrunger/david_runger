# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_stores_on_created_at  (created_at)
#  index_stores_on_user_id     (user_id)
#

class StoreSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :items
end
