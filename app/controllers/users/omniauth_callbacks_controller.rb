# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user, only: [:google_oauth2]

  def google_oauth2
    authorize(User, :create?)
    access_token = request.env['omniauth.auth']
    email = access_token.info['email']

    user = User.find_by(email: email)
    if !user
      user = Users::Create.new(email: email).run!.user
    end

    sign_in(user)
    redirect_to(session.delete('user_return_to') || root_path)
  end
end
