# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user, only: [:google_oauth2]

  def google_oauth2
    user = User.from_omniauth!(request.env['omniauth.auth'])
    sign_in(user)
    NewUserMailer.user_created(user.id).deliver_later
    redirect_to(session.delete('user_return_to') || groceries_path)
  end
end
