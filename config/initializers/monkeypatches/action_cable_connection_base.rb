# frozen_string_literal: true

require 'lograge'
require 'lograge/rails_ext/action_cable/connection/base'

module ConnectionInstrumentationMonkeypatch
  def notification_payload(method_name)
    # @ip and current_user are set in ApplicationCable::Connection#connect
    super.merge(ip: @ip, user_id: current_user&.id)
  end
end

ActiveSupport.on_load(:action_cable_connection) { prepend ConnectionInstrumentationMonkeypatch }
