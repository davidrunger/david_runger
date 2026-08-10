class Admin::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  class SubMismatch < StandardError ; end

  skip_before_action :authenticate_user!, only: [:google_oauth2]

  def google_oauth2
    skip_authorization

    access_token = request.env['omniauth.auth']
    email = access_token.info['email']
    sub = access_token.dig('extra', 'id_info', 'sub').presence!
    admin_user = AdminUser.find_by(email:)

    if admin_user
      # https://cyberinsider.com/unfixed-google-oauth-flaw-exposes-millions-to-account-takeovers/
      if admin_user.google_sub
        if sub != admin_user.google_sub
          Rails.error.report(
            Error.new(SubMismatch),
            context: {
              email:,
              admin_user_sub_in_db: admin_user.google_sub,
              sub_in_google_response: sub,
            },
          )

          flash[:alert] = 'You are attempting a domain identity takeover attack. Blocked!'
          redirect_to(new_admin_user_session_path)
          return
        end
      else
        admin_user.update!(google_sub: sub)
      end

      sign_in(admin_user)
      redirect_to(session.delete('admin_user_return_to') || admin_root_path)
    else
      flash[:alert] = "#{email} is not authorized to access admin"
      redirect_to(new_admin_user_session_path)
    end
  end
end
