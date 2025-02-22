class Api::Items::BulkUpdatesController < Api::BaseController
  before_action :ensure_items_present, only: %i[create]

  def create
    items.includes(:store, :user).find_each { |item| authorize(item, :update?) }
    Items::BulkUpdate::Create.run!(items: items.to_a, attributes_change: attributes_change.to_h)
    head(:no_content)
  end

  private

  def ensure_items_present
    head(:no_content) if items.empty?
  end

  def bulk_update_params
    params.expect(bulk_update: [item_ids: [], attributes_change: {}])
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
