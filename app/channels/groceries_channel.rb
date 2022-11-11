# frozen_string_literal: true

class GroceriesChannel < ApplicationCable::Channel
  def subscribed
    marriage = current_user.marriage.presence!
    authorize!(marriage, :show_groceries?)
    stream_for(marriage)
  end
end
