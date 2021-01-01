# frozen_string_literal: true

class Admin::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!, only: [:google_oauth2]

  def google_oauth2
    skip_authorization

    access_token = request.env['omniauth.auth']
    email = access_token.info['email']
    admin_user = AdminUser.find_by(email: email)

    if admin_user
      sign_in(admin_user)
      redirect_to(session.delete('user_return_to') || admin_root_path)
    else
      flash[:alert] = "#{email} is not authorized to access admin"
      redirect_to(admin_login_path)
    end
  end
end
