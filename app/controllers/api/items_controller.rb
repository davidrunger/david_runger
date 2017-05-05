class Api::ItemsController < ApplicationController
  def index
    store = current_user.stores.find(params[:store_id])
    @items = store.items.not_archived.order('items.created_at DESC')
    render :index
  end

  def create
    store = current_user.stores.find(params[:store_id])
    @item = store.items.create!(item_params)
    render :show
  end

  def update
    @item = current_user.items.find(params['id'])
    @item.update!(item_params)
    render :show
  end

  private

  def item_params
  	params.require(:item).permit(:name, :needed)
  end
end
