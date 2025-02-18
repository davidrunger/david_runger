class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!, only: [:google_oauth2]

  def google_oauth2
    authorize(User, :create?)
    access_token = request.env['omniauth.auth']
    email = access_token.info['email']

    user = User.find_by(email:)

    if user
      # https://cyberinsider.com/unfixed-google-oauth-flaw-exposes-millions-to-account-takeovers/
      sub = access_token.dig('extra', 'id_info', 'sub').presence!

      if user.google_sub
        if sub != user.google_sub
          flash[:alert] = 'You are attempting a domain identity takeover attack. Blocked!'
          redirect_to(new_user_session_path)
          return
        end
      else
        user.update!(google_sub: sub)
      end
    else
      user = Users::Create.run!(email:).user
    end

    sign_in(user)
    redirect_to(session.delete('user_return_to') || root_path)
  end
end
