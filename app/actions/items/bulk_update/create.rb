# frozen_string_literal: true

class Items::BulkUpdate::Create < ApplicationAction
  BULK_UPDATABLE_ATTRIBUTES = %w[needed].map(&:freeze).freeze

  requires :items, Array
  requires(
    :attributes_change,
    Shaped::Shapes::All.new(
      Hash,
      ->(hash) { hash.keys.all? { _1.in?(BULK_UPDATABLE_ATTRIBUTES) } },
    ),
  )

  def execute
    Item.transaction do
      items.each do |item|
        item.update!(attributes_change)
      end
    end
  end
end
