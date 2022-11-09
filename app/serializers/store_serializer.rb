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

class StoreSerializer < ApplicationSerializer
  attributes :id, :name, :notes, :own_store, :private, :viewed_at
  many :items, resource: ItemSerializer

  attribute(:own_store) do |store|
    own_store?(store)
  end

  attribute(:viewed_at) do |store|
    # match time format to the JavaScript one
    own_store?(store) ? store.viewed_at.utc.iso8601(3) : nil
  end

  private

  def own_store?(store)
    store.user_id == current_user.id
  end
end
