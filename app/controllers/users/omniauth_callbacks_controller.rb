class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  class SubMismatch < StandardError ; end

  skip_before_action :authenticate_user!, only: [:google_oauth2]

  def google_oauth2
    authorize(User, :create?)
    access_token = request.env['omniauth.auth']
    email = access_token.info['email']
    sub = access_token.dig('extra', 'id_info', 'sub').presence!

    user = User.find_by(email:)

    if user
      # https://cyberinsider.com/unfixed-google-oauth-flaw-exposes-millions-to-account-takeovers/
      if user.google_sub
        if sub != user.google_sub
          Rails.error.report(
            Error.new(SubMismatch),
            context: {
              user_sub_in_db: user.google_sub,
              sub_in_google_response: sub,
            },
          )

          flash[:alert] = 'You are attempting a domain identity takeover attack. Blocked!'
          redirect_to(new_user_session_path)
          return
        end
      else
        user.update!(google_sub: sub)
      end
    else
      user = Users::Create.run!(email:, google_sub: sub).user
    end

    sign_in(user)
    redirect_to(redirect_location || root_path)
  end
end
