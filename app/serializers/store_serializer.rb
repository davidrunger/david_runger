# frozen_string_literal: true

# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :integer
#  viewed_at  :datetime
#

class StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :viewed_at
  has_many :items
end
