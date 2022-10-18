# frozen_string_literal: true

# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  notes      :text
#  private    :boolean          default(FALSE), not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#  viewed_at  :datetime         not null
#
# Indexes
#
#  index_stores_on_user_id  (user_id)
#

class StoreSerializer < ActiveModel::Serializer
  attributes :id, :name, :notes, :own_store, :private, :viewed_at
  has_many :items

  def own_store
    own_store?
  end

  def viewed_at
    own_store? ? store.viewed_at.utc.iso8601(3) : nil # match time format to the JavaScript one
  end

  private

  def own_store?
    store.user_id == current_user.id
  end

  def store
    object
  end
end
