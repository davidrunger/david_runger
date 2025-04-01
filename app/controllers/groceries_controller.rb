class GroceriesController < ApplicationController
  def index
    authorize(Store)

    @title = 'Groceries'
    @ios_theme_color = '#e0e7ff'

    spouse = current_user.spouse

    bootstrap(
      current_user: UserSerializer::Basic.new(current_user),
      spouse: spouse && UserSerializer::Basic.new(spouse),
      own_stores:
        StoreSerializer.new(
          current_user.stores.includes(:items),
          params: { current_user: },
        ),
      spouse_stores:
        if spouse
          StoreSerializer.new(
            spouse.stores.where.not(private: true).includes(:items),
            params: { current_user: },
          )
        else
          []
        end,
    )
    render :index
  end
end
