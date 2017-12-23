class Api::ItemsController < ApplicationController
  def create
    store = current_user.stores.find(params[:store_id])
    @item = store.items.create!(item_params)
    render json: @item
  end

  def update
    @item = current_user.items.find(params['id'])
    @item.update!(item_params)
    render json: @item
  end

  def destroy
    @item = current_user.items.find(params['id'])
    @item.destroy!
    head 204
  end

  private

  def item_params
    params.require(:item).permit(:name, :needed, :store_id)
  end
end
