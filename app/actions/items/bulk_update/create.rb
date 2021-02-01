# frozen_string_literal: true

class Items::BulkUpdate::Create < ApplicationAction
  BULK_UPDATABLE_ATTRIBUTES = %w[needed].map(&:freeze).freeze

  class << self
    def only_updating_allowed_attributes?(hash)
      hash.keys.all? { _1.in?(BULK_UPDATABLE_ATTRIBUTES) }
    end
  end

  requires :items, Array
  requires(
    :attributes_change,
    Shaped::Shapes::All.new(Hash, method(:only_updating_allowed_attributes?)),
  )

  def execute
    Item.transaction do
      items.each do |item|
        item.update!(attributes_change)
      end
    end
  end
end
