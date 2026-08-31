class ItemMerges::Create < ApplicationAction
  requires :source_item, Item
  requires :target_item, Item

  returns :item, Item

  def execute
    if source_item.id == target_item.id
      raise(ActiveRecord::RecordNotFound)
    end

    result.item =
      Item.transaction do
        # Lock item rows by ID to prevent deadlocks between overlapping merges.
        items =
          Item.where(id: [source_item, target_item]).order(:id).lock.index_by(&:id)
        locked_source_item = items.fetch(source_item.id)
        locked_target_item = items.fetch(target_item.id)
        if locked_source_item.user_id != locked_target_item.user_id
          raise(ActiveRecord::RecordNotFound)
        end

        merge_availabilities(
          source_item: locked_source_item,
          target_item: locked_target_item,
        )
        locked_target_item.update!(
          needed: [locked_source_item.needed, locked_target_item.needed].max,
          # Force an update broadcast when the merged `needed` value is unchanged.
          updated_at: Time.current,
        )

        locked_source_item.item_availabilities.reset
        locked_source_item.destroy!
        locked_target_item.item_availabilities.reset
        locked_target_item.reload
      end
  end

  private

  def merge_availabilities(source_item:, target_item:)
    # Lock availability rows by ID to prevent deadlocks between overlapping merges.
    item_availabilities =
      ItemAvailability.
        where(item_id: [source_item, target_item]).
        order(:id).
        lock.
        to_a
    target_availabilities_by_store_id =
      item_availabilities.
        select { it.item_id == target_item.id }.
        index_by(&:store_id)

    item_availabilities.select { it.item_id == source_item.id }.each do |item_availability|
      if target_availabilities_by_store_id.key?(item_availability.store_id)
        item_availability.destroy!
      else
        item_availability.update!(item: target_item)
      end
    end
  end
end
