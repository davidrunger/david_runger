# frozen_string_literal: true

class Api::TextMessagesController < ApplicationController
  after_action :verify_authorized

  def create
    authorize(SmsRecord)

    sms_message = SmsMessage.new(
      user: current_user,
      message_type: text_message_params['message_type'],
      message_params: text_message_params['message_params'],
    )
    if !sms_message.valid?
      render_json_error(sms_message.errors.to_h)
    elsif !sms_message.send!
      render_json_error('We were unable to send the requested text message')
    else
      head :created
    end
  end

  private

  def text_message_params
    # strong params workaround to permit arbitrary keys for the nested message_params hash
    message_params_keys = params[:text_message][:message_params].keys
    params.require(:text_message).permit(:message_type, message_params: message_params_keys)
  end

  def user_not_authorized
    case params['action']
    when 'create'
      render_json_error('You are not authorized to send text messages', 403)
    else
      super
    end
  end
end
