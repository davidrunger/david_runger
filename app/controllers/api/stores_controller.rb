class Api::StoresController < ApplicationController
  def create
    @store = current_user.stores.build(store_params.merge(viewed_at: Time.current))
    if @store.save
      StatsD.increment('stores.create.success')
      render json: @store
    else
      StatsD.increment('stores.create.failure')
      render json: {errors: @store.errors.to_h}, status: 422
    end
  end

  def update
    @store = Store.find(params['id'])
    if @store.update(store_params)
      render json: @store
    else
      render json: {errors: @store.errors.to_h}, status: 422
    end
  end

  def destroy
    store = current_user.stores.find(params['id'])
    store.destroy!
    head 204
  end

  private

  def store_params
    params.require(:store).permit(:name, :viewed_at)
  end
end
