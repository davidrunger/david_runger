# frozen_string_literal: true

class GroceriesController < ApplicationController
  def index
    authorize(Store, :index?)
    @title = 'Groceries'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      stores:
        ActiveModel::Serializer::CollectionSerializer.new(current_user.stores.includes(:items)),
    )
    render :index
  end
end
