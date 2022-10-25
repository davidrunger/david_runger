# frozen_string_literal: true

class Api::ItemsController < ApplicationController
  before_action :set_item, only: %i[destroy update]

  def create
    authorize(Item)
    store = current_user.stores.find(params[:store_id])
    @item = store.items.build(item_params)
    if @item.save
      render json: @item, status: :created
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize(@item)
    if @item.update(item_params)
      render json: @item
    else
      render json: { errors: @item.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize(@item)
    @item.destroy!
    head :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :needed, :store_id)
  end

  def set_item
    @item ||= policy_scope(Item).find_by(id: params['id'])
    head(:not_found) if @item.nil?
  end
end
