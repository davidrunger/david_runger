# frozen_string_literal: true

class LogEntriesChannel < ApplicationCable::Channel
  def subscribed
    log = Log.find(params[:log_id])
    authorize!(log, :show?)
    stream_for(log)
  end
end
