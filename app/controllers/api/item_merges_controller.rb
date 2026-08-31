class Api::ItemMergesController < Api::BaseController
  def create
    source_item = policy_scope(Item).find(params.expect(:source_item_id))
    target_item = policy_scope(Item).find(params.expect(:target_item_id))
    authorize(source_item, :merge?)
    authorize(target_item, :merge?)

    item = ItemMerges::Create.run!(source_item:, target_item:).item

    render_schema_json(item)
  end
end
