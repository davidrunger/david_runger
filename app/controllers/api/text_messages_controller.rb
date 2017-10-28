class Api::TextMessagesController < ApplicationController
  MESSAGE_TYPES = %w[grocery_store_items_needed].map(&:freeze).freeze

  before_action :ensure_admin_user
  before_action :ensure_user_has_phone
  before_action :ensure_valid_message_type

  def create
    message_type = text_message_params['message_type']
    message_params = text_message_params['message_params']
    message = send("#{message_type}_message", message_params)
    if NexmoClient.send_text(number: current_user.phone, message: message).success?
      head :created
    else
      render_json_error('We were unable to send the requested text message')
    end
  end

  private

  def text_message_params
    # strong params workaround to permit arbitrary keys for the nested message_params hash
    message_params_keys = params[:text_message][:message_params].keys
    params.require(:text_message).permit(:message_type, message_params: message_params_keys)
  end

  def ensure_admin_user
    if !current_user.admin?
      render_json_error('Only admin users may send text messages.')
    end
  end

  def ensure_user_has_phone
    if !current_user.phone.present?
      render_json_error('We dont know your phone number and so we cannot text you.')
    end
  end

  def ensure_valid_message_type
    if !text_message_params['message_type'].in?(MESSAGE_TYPES)
      render_json_error('Invalid message_type', 422)
    end
  end

  def grocery_store_items_needed_message(message_params)
    store = Store.find(message_params['store_id'])
    store.items.
      where('items.needed > 0').
      sort_by { |item| item.name.downcase }.
      map { |item| "#{item.name} (#{item.needed})" }.
      join("\n")
  end
end
