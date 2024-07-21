class Api::Items::BulkUpdatesController < ApplicationController
  before_action :ensure_items_present, only: %i[create]

  def create
    items.includes(:store).find_each { |item| authorize(item, :update?) }
    Items::BulkUpdate::Create.run!(items: items.to_a, attributes_change: attributes_change.to_h)
    head(:no_content)
  end

  private

  def ensure_items_present
    head(:no_content) if items.empty?
  end

  def bulk_update_params
    params.require(:bulk_update).permit(item_ids: [], attributes_change: {})
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
