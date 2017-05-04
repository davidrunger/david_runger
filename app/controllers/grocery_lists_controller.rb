class GroceryListsController < ApplicationController
	skip_before_action :authenticate_user!, only: [:show]

	def show
		@title = 'Grocery List'
		bootstrap(current_user: current_user&.as_json)
		render :show
	end
end