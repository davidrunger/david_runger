class GroceriesController < ApplicationController
  def show
    @title = 'Groceries'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      stores:
        ActiveModel::Serializer::CollectionSerializer.new(current_user.stores.includes(:items)),
    )
    render :show
  end
end
