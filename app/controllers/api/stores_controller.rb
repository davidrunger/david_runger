class Api::StoresController < ApplicationController
  def create
    @store = current_user.stores.build(store_params)
    if @store.save
      render json: @store
    else
      render json: {errors: @store.errors.to_h}, status: 422
    end
  end

  private

  def store_params
    params.require(:store).permit(:name)
  end
end
