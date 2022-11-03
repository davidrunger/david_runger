# frozen_string_literal: true

class GroceriesController < ApplicationController
  def index
    authorize(Store)
    @title = 'Groceries'

    spouse = current_user.spouse

    bootstrap(
      current_user: UserSerializer.new(current_user),
      stores:
        ActiveModel::Serializer::CollectionSerializer.new(
          current_user.stores.includes(:items),
          scope: current_user,
          scope_name: :current_user,
        ),
      spouse_stores:
        if spouse
          ActiveModel::Serializer::CollectionSerializer.new(
            spouse.stores.where.not(private: true).includes(:items),
            scope: current_user,
            scope_name: :current_user,
          )
        else
          []
        end,
    )
    render :index
  end
end
