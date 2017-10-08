class GroceriesController < ApplicationController
	def show
		@title = 'Groceries'
    bootstrap(
      current_user: current_user&.as_json,
      stores: ActiveModel::Serializer::CollectionSerializer.new(current_user.stores.includes(:items)),
    )
		render :show
	end
end
