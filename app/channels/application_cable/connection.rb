class ApplicationCable::Connection < ActionCable::Connection::Base
  identified_by :current_user

  def connect
    self.current_user = find_verified_user
    @ip = request.remote_ip
  end

  private

  def find_verified_user
    env['warden'].user || reject_unauthorized_connection
  end
end
