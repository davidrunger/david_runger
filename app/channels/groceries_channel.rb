# frozen_string_literal: true

class GroceriesChannel < ApplicationCable::Channel
  def subscribed
    user = User.find(params[:user_id])
    authorize!(user, :show_groceries?)
    stream_for(user)
  end
end
