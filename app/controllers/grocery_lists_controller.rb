class GroceryListsController < ApplicationController
	def show
		@title = 'Grocery List'
		bootstrap(current_user: current_user&.as_json)
		render :show
	end
end
