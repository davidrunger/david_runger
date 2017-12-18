class GroceriesController < ApplicationController
  def show
    @title = 'Groceries'
    @description = <<~DESCRIPION.squish
      A free and convenient online app for keeping track of groceries and other items that you want
      or need
    DESCRIPION
    bootstrap(
      current_user: current_user&.as_json,
      stores:
        ActiveModel::Serializer::CollectionSerializer.new(current_user.stores.includes(:items)),
    )
    render :show
  end
end
