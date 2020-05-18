# frozen_string_literal: true

# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint
#  viewed_at  :datetime
#
# Indexes
#
#  index_stores_on_user_id  (user_id)
#

class StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :viewed_at
  has_many :items
end
