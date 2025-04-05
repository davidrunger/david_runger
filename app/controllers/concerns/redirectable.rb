module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :store_redirect_location
  end

  def redirect_location
    session.delete(:redirect_location).presence ||
      session.delete('user_return_to').presence
  end

  def store_redirect_location
    if (
      redirect_location =
        params[:redirect_location] ||
        request.env['omniauth.origin'].presence.then do |omniauth_origin|
          unless omniauth_origin.in?([new_user_session_url, new_admin_user_session_url])
            omniauth_origin
          end
        end
    )
      session[:redirect_location] = redirect_location
    end
  end
end
