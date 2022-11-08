# frozen_string_literal: true

class CheckInsChannel < ApplicationCable::Channel
  def subscribed
    marriage = current_user.marriage.presence!
    authorize!(marriage, :show?)
    stream_for(marriage)
  end
end
