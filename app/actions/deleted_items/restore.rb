class DeletedItems::Restore < ApplicationAction
  requires :item_availability_versions, [PaperTrail::Version]
  requires :item_version, PaperTrail::Version

  returns :item, Item

  def execute
    item = item_version.reify
    item_availabilities = item_availability_versions.map(&:reify)
    stores_by_id =
      item.user.stores.where(
        id: item_availabilities.map(&:store_id),
      ).index_by(&:id)
    if !valid_item_availabilities?(item:, item_availabilities:, stores_by_id:)
      raise(ActiveRecord::RecordNotFound)
    end

    Item.transaction do
      item_availabilities.each do |item_availability|
        item_availability.store = stores_by_id.fetch(item_availability.store_id)
        item.item_availabilities << item_availability
      end
      item.save!
    end

    result.item = item
  end

  private

  def valid_item_availabilities?(item:, item_availabilities:, stores_by_id:)
    if item_availabilities.empty?
      false
    else
      item_availabilities.all? do |item_availability|
        item_availability.item_id == item.id &&
          stores_by_id.key?(item_availability.store_id)
      end
    end
  end
end
