class Api::Items::BulkUpdatesController < Api::BaseController
  before_action :ensure_items_present, only: %i[create]

  def create
    items_with_associations = items.includes(:item_availabilities, :user).to_a
    items_with_associations.each do |item|
      authorize(item, :update?)
    end
    Items::BulkUpdate::Create.run!(
      items: items_with_associations,
      attributes_change: attributes_change.to_h,
    )
    head(:no_content)
  end

  private

  def ensure_items_present
    if items.empty?
      head(:no_content)
    end
  end

  def bulk_update_params
    params.expect(bulk_update: [{ item_ids: [], attributes_change: {} }])
  end

  def attributes_change
    bulk_update_params[:attributes_change]
  end

  def item_ids
    bulk_update_params[:item_ids]
  end

  def items
    policy_scope(Item).where(id: item_ids)
  end
end
