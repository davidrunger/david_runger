class Api::ItemsController < Api::BaseController
  before_action :set_item, only: %i[destroy update]

  def create
    authorize(Item)
    store = current_user.stores.find(params[:store_id])
    @item = store.items.build(item_params)
    if @item.save
      render_schema_json(@item, status: :created)
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    authorize(@item)
    if @item.update(item_params)
      render_schema_json(@item)
    else
      render json: { errors: @item.errors.to_hash }, status: :unprocessable_content
    end
  end

  def destroy
    authorize(@item)

    @item.destroy!

    render_schema_json({
      restore_item_path:
        api_reifications_path(
          paper_trail_version_id: @item.versions.destroys.last!.id,
        ),
    })
  end

  private

  def item_params
    params.expect(item: %i[name needed store_id])
  end

  def set_item
    @item = policy_scope(Item).find_by(id: params['id'])

    head(:not_found) if @item.nil?
  end
end
