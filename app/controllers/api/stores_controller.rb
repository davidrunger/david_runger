# frozen_string_literal: true

class Api::StoresController < ApplicationController
  before_action :set_store, only: %i[destroy update]

  def create
    @store = current_user.stores.build(store_params.merge(viewed_at: Time.current))
    if @store.save
      StatsD.increment('stores.create.success')
      render json: @store, status: :created
    else
      StatsD.increment('stores.create.failure')
      render json: {errors: @store.errors.to_h}, status: :unprocessable_entity
    end
  end

  def update
    if @store.update(store_params)
      render json: @store
    else
      render json: {errors: @store.errors.to_h}, status: :unprocessable_entity
    end
  end

  def destroy
    @store.destroy!
    head(204)
  end

  private

  def set_store
    @store = current_user.stores.find_by(id: params['id'])
    head(404) if @store.nil?
  end

  def store_params
    params.require(:store).permit(:name, :viewed_at)
  end
end
