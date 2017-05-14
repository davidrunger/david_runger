class GroceryListsController < ApplicationController
	def show
		@title = 'Grocery List'
    bootstrap(
      current_user: current_user&.as_json,
      stores: ActiveModel::ArraySerializer.new(current_user.stores.order('stores.created_at DESC')),
    )
		render :show
	end
end
