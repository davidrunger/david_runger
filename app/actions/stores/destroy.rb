class Stores::Destroy < ApplicationAction
  requires :store, Store

  def execute
    items = store.items.includes(item_availabilities: :item_section_assignments)
    items_to_destroy, items_to_update =
      items.partition { |item| item.item_availabilities.one? }
    store_for_destroy = Store.with_eager_loading_for_destroy.find(store.id)

    Store.transaction do
      store_for_destroy.destroy!
      items_to_destroy.each(&:destroy!)
      items_to_update.each do |item|
        item.item_availabilities.reset
        # Trigger the `after_update_commit` broadcast for the availability change.
        item.touch # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
